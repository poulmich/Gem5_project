#!/bin/bash

# Base directory where all the test folders are located
BASE_OUTPUT_DIR="/home/arch/gem5_files/part_3/test/speclibm/"

# Output file to store the extracted CPI values with their test folders
OUTPUT_FILE="${BASE_OUTPUT_DIR}cpi_results.txt"

# Temporary file for storing CPI values and their test folders
TEMP_FILE="${BASE_OUTPUT_DIR}cpi_values.tmp"

# Initialize the output files
echo "Test Folder, CPI" > "$OUTPUT_FILE"
> "$TEMP_FILE" # Clear the temporary file

# Function to extract CPI from a given stats.txt file
extract_cpi() {
    local stats_file="$1"
    local cpi_value

    # Extract the CPI value using grep and awk
    cpi_value=$(grep -E "^system\.cpu\.cpi" "$stats_file" | awk '{print $2}')
    
    # Return the extracted CPI value
    echo "$cpi_value"
}

# Recursively iterate through all test directories
find "$BASE_OUTPUT_DIR" -type f -name "stats.txt" | while read -r stats_file; do
    # Get the directory name containing the stats.txt
    test_folder=$(dirname "$stats_file")

    # Extract the CPI value
    cpi=$(extract_cpi "$stats_file")

    # Append the result to the output file and temporary file
    echo "${test_folder}, ${cpi}" >> "$OUTPUT_FILE"
    echo "${cpi} ${test_folder}" >> "$TEMP_FILE"
done

# Find the minimum CPI value and its corresponding test folder
read min_cpi min_test_folder < <(awk 'NR == 1 || $1 < min {min = $1; folder = $2} END {print min, folder}' "$TEMP_FILE")

# Clean up temporary file
rm -f "$TEMP_FILE"

# Print the minimum CPI value and its test folder
echo "CPI extraction completed. Results saved to $OUTPUT_FILE."
echo "Minimum CPI: $min_cpi (from $min_test_folder)"

