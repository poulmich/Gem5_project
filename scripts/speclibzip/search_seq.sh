#!/bin/bash

BASE_OUTPUT_DIR="/home/arch/gem5_files/part_3/test/speclibzip/"

# Default cache parameters
DEFAULT_L2_SIZE=512kB
DEFAULT_L1D_SIZE=32kB
DEFAULT_L1I_SIZE=16kB
DEFAULT_L2_ASSOC=2
DEFAULT_L1D_ASSOC=1
DEFAULT_L1I_ASSOC=1
DEFAULT_CACHELINE_SIZE=64

# Command template
CMD="/home/arch/Desktop/gem5/build/ARM/gem5.opt"

# Function to run simulation with given parameters
run_simulation() {
    OUTPUT_DIR="$1"
    L1D_SIZE="$2"
    L1I_SIZE="$3"
    L2_SIZE="$4"
    L1D_ASSOC="$5"
    L1I_ASSOC="$6"
    L2_ASSOC="$7"
    CACHELINE_SIZE="$8"

    mkdir -p "$OUTPUT_DIR"

    $CMD \
        -d "$OUTPUT_DIR" \
        /home/arch/Desktop/gem5/configs/example/se.py \
        --cpu-type=MinorCPU \
        --caches \
        --l2cache \
        --cpu-clock=1GHz \
        --l1d_size="$L1D_SIZE" \
        --l1i_size="$L1I_SIZE" \
        --l2_size="$L2_SIZE" \
        --l1d_assoc="$L1D_ASSOC" \
        --l1i_assoc="$L1I_ASSOC" \
        --l2_assoc="$L2_ASSOC" \
        --cacheline_size="$CACHELINE_SIZE" \
        -c /home/arch/spec_cpu2006/401.bzip2/src/specbzip \
        -o "/home/arch/spec_cpu2006/401.bzip2/data/input.program 10"\
        -I 1000000
}

# 1. Varying L2 cache size
L2_SIZES=( 512kB 1MB 2MB 4MB)
for L2_SIZE in "${L2_SIZES[@]}"; do
    run_simulation "${BASE_OUTPUT_DIR}l2/${L2_SIZE}" "$DEFAULT_L1D_SIZE" "$DEFAULT_L1I_SIZE" "$L2_SIZE" "$DEFAULT_L1D_ASSOC" "$DEFAULT_L1I_ASSOC" "$DEFAULT_L2_ASSOC" "$DEFAULT_CACHELINE_SIZE"
done

# 2. Varying L1D cache size
L1D_SIZES=(16kB 32kB 64kB 128kB)
for L1D_SIZE in "${L1D_SIZES[@]}"; do
    run_simulation "${BASE_OUTPUT_DIR}l1d/${L1D_SIZE}" "$L1D_SIZE" "$DEFAULT_L1I_SIZE" "$DEFAULT_L2_SIZE" "$DEFAULT_L1D_ASSOC" "$DEFAULT_L1I_ASSOC" "$DEFAULT_L2_ASSOC" "$DEFAULT_CACHELINE_SIZE"
done

# 3. Varying L1I cache size
L1I_SIZES=(16kB 32kB 64kB 128kB)
for L1I_SIZE in "${L1I_SIZES[@]}"; do
    L1I_SIZE_NUM=${L1I_SIZE%kB}
    DEFAULT_L1D_SIZE_NUM=${DEFAULT_L1D_SIZE%kB}
    if [ $((L1I_SIZE_NUM + DEFAULT_L1D_SIZE_NUM)) -le 256 ]; then
        run_simulation "${BASE_OUTPUT_DIR}l1i/${L1I_SIZE}" "$DEFAULT_L1D_SIZE" "$L1I_SIZE" "$DEFAULT_L2_SIZE" "$DEFAULT_L1D_ASSOC" "$DEFAULT_L1I_ASSOC" "$DEFAULT_L2_ASSOC" "$DEFAULT_CACHELINE_SIZE"
    fi
done

# 4. Varying L2 associativity
L2_ASSOCS=(1 2 4 8 16 32)
for L2_ASSOC in "${L2_ASSOCS[@]}"; do
    run_simulation "${BASE_OUTPUT_DIR}l2_assoc/${L2_ASSOC}" "$DEFAULT_L1D_SIZE" "$DEFAULT_L1I_SIZE" "$DEFAULT_L2_SIZE" "$DEFAULT_L1D_ASSOC" "$DEFAULT_L1I_ASSOC" "$L2_ASSOC" "$DEFAULT_CACHELINE_SIZE"
done

# 5. Varying L1I associativity
L1_ASSOCS=(1 2 4 8 16 32)
for L1_ASSOC in "${L1_ASSOCS[@]}"; do
    run_simulation "${BASE_OUTPUT_DIR}l1i_assoc/${L1_ASSOC}" "$DEFAULT_L1D_SIZE" "$DEFAULT_L1I_SIZE" "$DEFAULT_L2_SIZE" "$L1_ASSOC" "$DEFAULT_L1I_ASSOC" "$DEFAULT_L2_ASSOC" "$DEFAULT_CACHELINE_SIZE"
done

# 6. Varying L1D associativity
L1_ASSOCS=(1 2 4 8 16 32)
for L1_ASSOC in "${L1_ASSOCS[@]}"; do
    run_simulation "${BASE_OUTPUT_DIR}l1d_assoc/${L1_ASSOC}" "$DEFAULT_L1D_SIZE" "$DEFAULT_L1I_SIZE" "$DEFAULT_L2_SIZE" "$DEFAULT_L1I_ASSOC" "$L1_ASSOC" "$DEFAULT_L2_ASSOC" "$DEFAULT_CACHELINE_SIZE"
done

# 7. Varying cache line size
CACHELINE_SIZES=(16 32 64 128 256)
for CACHELINE_SIZE in "${CACHELINE_SIZES[@]}"; do
    run_simulation "${BASE_OUTPUT_DIR}cacheline/${CACHELINE_SIZE}" "$DEFAULT_L1D_SIZE" "$DEFAULT_L1I_SIZE" "$DEFAULT_L2_SIZE" "$DEFAULT_L1D_ASSOC" "$DEFAULT_L1I_ASSOC" "$DEFAULT_L2_ASSOC" "$CACHELINE_SIZE"
done

echo "All simulations completed."

