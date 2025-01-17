#!/bin/bash

# Base directory containing simulation folders
BASE_OUTPUT_DIR="/home/arch/gem5_files/part_3/specsjeng"

# Output file for storing CPI values
CPI_OUTPUT_FILE="cpi_values.txt"
> "$CPI_OUTPUT_FILE" # Clear the output file if it exists

# Variable to track the minimum CPI and corresponding folder
MIN_CPI=999999
MIN_FOLDER=""

# Loop through all subdirectories in the base directory
for FOLDER in "$BASE_OUTPUT_DIR"/*/; do
    # Check if the folder exists (to handle cases where there are no subdirectories)
    if [[ -d "$FOLDER" ]]; then
        # Extract the folder name
        FOLDER_NAME=$(basename "$FOLDER")

        # Path to stats.txt
        STATS_FILE="${FOLDER}/stats.txt"

        # Check if stats.txt exists
        if [[ -f "$STATS_FILE" ]]; then
            # Extract the system.cpu.cpi value
            CPI_VALUE=$(grep "system.cpu.cpi" "$STATS_FILE" | awk '{print $2}')
            
            # Check if a valid CPI value was found
            if [[ -n "$CPI_VALUE" ]]; then
                # Write the folder name and CPI value to the output file
                echo "$FOLDER_NAME: $CPI_VALUE" >> "$CPI_OUTPUT_FILE"
                
                # Update the minimum CPI if necessary
                if (( $(echo "$CPI_VALUE < $MIN_CPI" | bc -l) )); then
                    MIN_CPI="$CPI_VALUE"
                    MIN_FOLDER="$FOLDER_NAME"
                fi
            else
                echo "$FOLDER_NAME: CPI not found" >> "$CPI_OUTPUT_FILE"
            fi
        else
            echo "$FOLDER_NAME: stats.txt not found" >> "$CPI_OUTPUT_FILE"
        fi
    fi
done

# Print the minimum CPI value and corresponding folder
if [[ -n "$MIN_FOLDER" ]]; then
    echo "Minimum CPI: $MIN_CPI (Folder $MIN_FOLDER)"
else
    echo "No valid CPI values found."
fi

# Output completion message
echo "CPI values extracted. Check $CPI_OUTPUT_FILE for results."

