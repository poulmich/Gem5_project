#!/bin/bash

# Base output directory
BASE_OUTPUT_DIR="/home/arch/gem5_files/part_3/specmcf/"

# Define parameter values
L2_SIZES=("256kB" "512kB" "1MB" "2MB" "4MB")
L1_SIZES=("16kB,16kB" "32kB,32kB" "64kB,64kB" "128kB,128kB")
L2_ASSOCS=(1 2 4 8)
L1_ASSOCS=(1 2 4 8)
CACHE_LINES=(16 32 64 128)

# Mapping file to track parameters
MAPPING_FILE="simulation_mapping_specmcf.txt"
> "$MAPPING_FILE" # Clear the mapping file if it exists

# Counter for folder numbering
COUNTER=1

# Iterate through all parameter combinations
for L2_SIZE in "${L2_SIZES[@]}"; do
    for L1_SIZE_PAIR in "${L1_SIZES[@]}"; do
        IFS=',' read -r L1I_SIZE L1D_SIZE <<< "$L1_SIZE_PAIR"
        for L2_ASSOC in "${L2_ASSOCS[@]}"; do
             for L1I_ASSOC in "${L1_ASSOCS[@]}"; do
              for L1D_ASSOC in "${L1_ASSOCS[@]}"; do
                for CACHE_LINE in "${CACHE_LINES[@]}"; do
                    # Create a unique folder for this combination
                    OUTPUT_DIR="${BASE_OUTPUT_DIR}${COUNTER}"
                    mkdir -p "$OUTPUT_DIR"
                    
                    # Write to the mapping file
                    echo "$COUNTER: l1i_size=$L1I_SIZE, l1d_size=$L1D_SIZE, l1_assoc=$L1_ASSOC, l2_assoc=$L2_ASSOC, l2_size=$L2_SIZE, cache_line=$CACHE_LINE" >> "$MAPPING_FILE"
                    
                    # Run the gem5 simulation
                    /home/arch/Desktop/gem5/build/ARM/gem5.opt \
                        -d "$OUTPUT_DIR" \
                        /home/arch/Desktop/gem5/configs/example/se.py \
                        --cpu-type=MinorCPU \
                        --caches \
                        --l2cache \
                        --l1d_size="$L1D_SIZE" \
                        --l1i_size="$L1I_SIZE" \
                        --l2_size="$L2_SIZE" \
                        --l1i_assoc="$L1I_ASSOC" \
                        --l1d_assoc="$L1D_ASSOC" \
                        --l2_assoc="$L2_ASSOC" \
                        --cacheline_size="$CACHE_LINE" \
                        --cpu-clock=1GHz \
                        -c /home/arch/spec_cpu2006/429.mcf/src/specmcf \
                        -o "/home/arch/spec_cpu2006/429.mcf/data/inp.in" \
                        -I 1000000
                    
                    # Increment folder counter
                    ((COUNTER++))
                done
            done
        done
    done
  done
done 
# Output completion message
echo "Simulations completed. Check $MAPPING_FILE for parameter mapping."
