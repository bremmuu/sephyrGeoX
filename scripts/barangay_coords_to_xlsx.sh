#!/bin/bash

JSON_FILE="../data/phl_admin_boundaries.json"
OUTPUT_DIR="../output"
mkdir -p "$OUTPUT_DIR"

normalize_input() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[ -]//g' | sed 's/n/ñ/g'
}

get_user_input() {
    local prompt="$1"
    local allow_empty="$2"
    local input
    while true; do
        read -rp "$prompt" input
        if [[ -n "$input" || "$allow_empty" == "true" ]]; then
            normalize_input "$input"
            return
        fi
    done
}

process_json() {
    local name1="$1"
    local name2="$2"
    local name3="$3"
    local varname3="$4"
    jq -r --arg n1 "$name1" \
        --arg n2 "$name2" \
        --arg n3 "$name3" \
        --arg v3 "$varname3" '
        .features[] | 
        select((($n1 == "" or (.properties.NAME_1 | ascii_downcase | gsub("[- ]"; "") | gsub("n"; "ñ") | contains($n1))) and 
                ($n2 == "" or (.properties.NAME_2 | ascii_downcase | gsub("[- ]"; "") | gsub("n"; "ñ") | contains($n2))) and 
                ($n3 == "" or (.properties.NAME_3 | ascii_downcase | gsub("[- ]"; "") | gsub("n"; "ñ") | contains($n3))) and 
                ($v3 == "" or (.properties.VARNAME_3 | ascii_downcase | gsub("[- ]"; "") | gsub("n"; "ñ") | contains($v3))))) |
        .properties.NAME_2 as $name2 |
        .properties.NAME_3 as $name3 | 
        .geometry.coordinates[][][] | 
        [$name2, $name3, .[1], .[0]] | @tsv' "$JSON_FILE"
}

while true; do
    echo -e "\n--- Extract Coordinates to XLSX ---"
    NAME1=$(get_user_input "Enter NAME_1 (or leave blank): " true)
    NAME2=$(get_user_input "Enter NAME_2 (or leave blank): " true)
    NAME3=$(get_user_input "Enter NAME_3 (or leave blank): " true)
    VARNAME3=$(get_user_input "Enter VARNAME_3 (or leave blank): " true)

    COORDINATES=$(process_json "$NAME1" "$NAME2" "$NAME3" "$VARNAME3")

    if [[ -z "$COORDINATES" ]]; then
        echo "No matching data found. Try again."
        continue
    fi

    echo -e "\nExtracted Coordinates with NAME_2 and NAME_3:"
    echo "$COORDINATES" | awk '{print NR ". NAME_2: "$1" | NAME_3: "$2" | Lat: "$3", Lon: "$4}'
    
# Extract unique NAME_2 values
UNIQUE_NAMES2=($(echo "$COORDINATES" | awk '{print $1}' | sort -u))
if [[ ${#UNIQUE_NAMES2[@]} -gt 1 ]]; then
    echo -e "\nMultiple NAME_2 values found:"
    for i in "${!UNIQUE_NAMES2[@]}"; do
        echo "$((i+1)). ${UNIQUE_NAMES2[$i]}"
    done
    read -rp "Select NAME_2 (enter number): " NAME2_CHOICE
    NAME2_SELECTED="${UNIQUE_NAMES2[$((NAME2_CHOICE-1))]}"
else
    NAME2_SELECTED="${UNIQUE_NAMES2[0]}"
fi

# Filter COORDINATES by selected NAME_2
COORDINATES=$(echo "$COORDINATES" | awk -v name2="$NAME2_SELECTED" '$1 == name2 {print}')
echo "DEBUG: Filtered COORDINATES after NAME_2 selection:"
echo "$COORDINATES"

# Extract unique NAME_3 values
UNIQUE_NAMES3=($(echo "$COORDINATES" | awk '{print $2}' | sort -u))
if [[ ${#UNIQUE_NAMES3[@]} -gt 1 ]]; then
    echo -e "\nMultiple NAME_3 values found:"
    for i in "${!UNIQUE_NAMES3[@]}"; do
        echo "$((i+1)). ${UNIQUE_NAMES3[$i]}"
    done
    read -rp "Select NAME_3 (enter number): " NAME3_CHOICE
    NAME3_SELECTED="${UNIQUE_NAMES3[$((NAME3_CHOICE-1))]}"
else
    NAME3_SELECTED="${UNIQUE_NAMES3[0]}"
fi

# Filter COORDINATES by selected NAME_3
COORDINATES=$(echo "$COORDINATES" | awk -v name3="$NAME3_SELECTED" '$2 == name3 {print}')
echo "DEBUG: Filtered COORDINATES after NAME_3 selection:"
echo "$COORDINATES"

# Ensure values are not empty
if [[ -z "$NAME2_SELECTED" || -z "$NAME3_SELECTED" ]]; then
    echo "Error: One or both selected names are empty."
    exit 1
fi

# Prompt for Municipality ID
read -rp "Enter Municipality ID: " MUNICIPALITY_ID

# Generate filename (convert to uppercase, replace spaces, handle special characters)
FILENAME="$(echo "${NAME3_SELECTED}_${NAME2_SELECTED}" | tr '[:lower:]' '[:upper:]' | sed 's/ñ/N/g' | tr ' ' '_')"
FILENAME="${FILENAME}.xlsx" 
FILE_PATH="$OUTPUT_DIR/$FILENAME"

# Debugging output
echo "DEBUG: Generated filename: $FILENAME"
echo "DEBUG: File will be saved at: $FILE_PATH"

# Continue with processing...


    {
        echo -e "municipality_id\tlatitude\tlongitude\tsequence_no"
        awk -v id="$MUNICIPALITY_ID" 'BEGIN {seq=1} {print id "\t" $3 "\t" $4 "\t" seq; seq++}' <<< "$COORDINATES"
    } > "$FILE_PATH"

    echo "Success! Saved as $FILE_PATH"

    echo -e "\nSwapped Longitude, Latitude values (for Keene State map tool):"
    echo "$COORDINATES" | awk '{print $4 "," $3}'
    echo -e "\nCopy and paste the above coordinates into https://www.keene.edu/campus/maps/tool/ to verify the locations."

    read -rp "Do you want to process another? (Y/n): " AGAIN
    AGAIN=${AGAIN,,}  
    if [[ -n "$AGAIN" && "$AGAIN" != "y" ]]; then
        break
    fi

done
