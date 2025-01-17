#!/bin/bash

# Base folders containing scripts to execute
FOLDERS=("speclibzip" "spechmmer" "speclibm" "specsjeng" "specmcf")

# Log file to store execution results
LOG_FILE="./execution_results.log"

# Clear the log file if it exists
> "$LOG_FILE"

echo "Starting script execution..." | tee -a "$LOG_FILE"

# Loop through each folder
for folder in "${FOLDERS[@]}"; do
    echo "Processing folder: $folder" | tee -a "$LOG_FILE"

    # Find all executable scripts in the current folder and its subdirectories
    find "$folder" -type f -executable | while read -r script; do
        echo "Executing script: $script" | tee -a "$LOG_FILE"

        # Execute the script and log the output and errors
        {
            echo "----- Output of $script -----"
            "$script"
            echo "----- End of Output -----"
        } >> "$LOG_FILE" 2>&1

        echo "Finished executing: $script" | tee -a "$LOG_FILE"
    done
done

echo "All scripts executed. Results are stored in $LOG_FILE."

