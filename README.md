# SephyrGeoX

SephyrGeoX is a shell script tool designed to fetch, filter, and organize barangay coordinates in the Philippines. It streamlines the process of generating XLSX files for administrative boundary mapping and prepares data for uploading to the [DepEd School GIS](https://depedschool.tekteachlms.com/) backend web app.

## Features
- Fetch barangay coordinates for easy filtering by municipality.
- Assign IDs to barangays and verify coordinates using the [Keene State Map Tool](https://www.keene.edu/campus/maps/tool/).
- Automate XLSX file generation with filenames based on barangay and municipality.
- Organize output files into user-defined directories (e.g., "Region 5").
- Allows smooth transition between batch processing of XLSX files.
- Uses a JSON dataset containing Philippine administrative boundaries from the GADM dataset.

## Installation
### Linux (Fedora, Ubuntu, Arch, etc.)
1. Clone the repository:
   ```sh
   git clone https://github.com/bremmuu/sephyrGeoX.git
   cd sephyrGeoX
   ```
2. Ensure dependencies are installed:
   ```sh
   sudo dnf install -y jq python3 xlsxwriter  # Fedora
   sudo apt install -y jq python3 xlsxwriter  # Debian/Ubuntu
   sudo pacman -S jq python-xlsxwriter        # Arch Linux
   ```
3. Make the script executable:
   ```sh
   chmod +x sephyrGeoX.sh
   ```
4. Run the script:
   ```sh
   ./sephyrGeoX.sh
   ```

### Windows (Executable Version)
SephyrGeoX will be packaged into a `.exe` file for Windows users, ensuring all dependencies are included.
- A pre-built executable will be available for download (coming soon).
- Alternatively, Windows users can run the script using Git Bash or WSL (Windows Subsystem for Linux).

## Usage
1. Run `sephyrGeoX.sh` and follow the prompts.
2. Assign an ID to the barangay and verify coordinates using the Keene State Map Tool.
3. Generate an XLSX file, named appropriately based on barangay and municipality.
4. Organize the generated files into a structured directory.
5. Upload the output to the DepEd School GIS website.

## Future Improvements
- Windows `.exe` packaging for easy execution without Python installation.
- Enhanced error handling and validation for coordinate verification.
- UI-based interface for non-technical users.

## License
This project is licensed under the **Sephyr License**:

- You are free to use, modify, and share this project.
- Credit to the original author (**Brem Sephyr**) is appreciated but not required.
- If this project helps you, consider giving a shoutout or a star on GitHub!
- No warranties or guarantees—use at your own risk!

## Author
Developed by **Brem Sephyr** ([bremmuu](https://github.com/bremmuu)).

