import pandas as pd
import numpy as np
import glob
import os
from scipy.spatial import ConvexHull

# Directory containing XLSX files
output_dir = "../output/"
xlsx_files = glob.glob(os.path.join(output_dir, "*.xlsx"))

# Ensure XLSX files exist
if not xlsx_files:
    print("No XLSX files found in ../output/")
    exit(1)

# List available files
print("\nAvailable XLSX files:")
for i, file in enumerate(xlsx_files):
    print(f"{i + 1}. {os.path.basename(file)}")

# User selects a file
while True:
    try:
        choice = int(input("\nEnter the number of the file to process: ")) - 1
        if 0 <= choice < len(xlsx_files):
            selected_file = xlsx_files[choice]
            break
        else:
            print("Invalid selection. Try again.")
    except ValueError:
        print("Please enter a valid number.")

print(f"\nProcessing: {selected_file}")

# Try reading as Excel first
try:
    df = pd.read_excel(selected_file, engine="openpyxl")
except Exception:
    print("File is not a valid Excel file. Trying as TSV...")
    df = pd.read_csv(selected_file, sep="\t")  # Read as TSV

# Normalize column names
df.columns = df.columns.str.strip().str.lower()

# Print detected columns
print("\nDetected columns:", df.columns.tolist())

# Ensure correct columns exist
expected_cols = {"municipality_id", "longitude", "latitude"}
if not expected_cols.issubset(df.columns):
    print("Error: Expected columns not found in the file!")
    exit(1)

print("File loaded successfully!")

# Drop duplicate lat/lon pairs while keeping the first occurrence
df = df.drop_duplicates(subset=["latitude", "longitude"], keep="first").reset_index(drop=True)

# Convert latitude and longitude to NumPy array
points = df[["longitude", "latitude"]].to_numpy()

# Compute the Convex Hull
hull = ConvexHull(points)
hull_points = points[hull.vertices]  # Ordered points forming the closed shape

# Create new DataFrame with corrected sequence numbers
fixed_df = pd.DataFrame(hull_points, columns=["longitude", "latitude"])
fixed_df.insert(0, "municipality_id", df["municipality_id"].iloc[0])  # Keep same ID
fixed_df["sequence_no"] = range(1, len(fixed_df) + 1)  # Assign new sequence numbers

# Append first point at the end to close the shape
first_point = fixed_df.iloc[0]
fixed_df = pd.concat([fixed_df, first_point.to_frame().T], ignore_index=True)
fixed_df["sequence_no"] = range(1, len(fixed_df) + 1)

# 🔥 **Reorder columns to: municipality_id, latitude, longitude, sequence_no**
fixed_df = fixed_df[["municipality_id", "latitude", "longitude", "sequence_no"]]

# Save as TSV but with .xlsx extension
output_file = os.path.join(output_dir, "fixed_" + os.path.basename(selected_file))
fixed_df.to_csv(output_file, sep="\t", index=False, encoding="utf-8")

print(f"\n✅ Fixed sequence saved as TSV format inside: {output_file} (but with .xlsx extension!)")
