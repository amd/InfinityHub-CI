#!/bin/bash
#
# Run CP2K DFT benchmark with 4 MPI ranks using ssitaram/cp2k:pr22 container
#

set -e

CONTAINER_IMAGE="localhost/cp2k:latest"
NUM_RANKS=16
NUM_GPUS=${NUM_GPUS:-8}
NUM_CPUS=${NUM_CPUS:-128}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-4}
CP2K_BRANCH="v2026.1"
BENCHMARK_INPUT="/cp2k_source/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp"
OUTPUT_FILE="/tmp/H2O-DFT-LS-NREP2-16ranks.txt"
CP2K_EXECUTABLE="cp2k.psmp"

echo "=========================================="
echo "Running CP2K DFT Benchmark"
echo "Container: $CONTAINER_IMAGE"
echo "MPI Ranks: $NUM_RANKS"
echo "OpenMP Threads per rank: $OMP_NUM_THREADS"
echo "Executable: $CP2K_EXECUTABLE"
echo "CP2K Branch: $CP2K_BRANCH"
echo "=========================================="

# Get the script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the docker directory (parent of scripts)
DOCKER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Get the base directory (parent of docker)
BASE_DIR="$(cd "$DOCKER_DIR/.." && pwd)"

# Clone CP2K repository if not already present
if [ ! -d "$BASE_DIR/cp2k_repo" ]; then
    echo "Cloning CP2K repository (branch ${CP2K_BRANCH})..."
    cd "$BASE_DIR"
    git clone --recursive -b ${CP2K_BRANCH} https://github.com/cp2k/cp2k.git cp2k_repo
else
    echo "CP2K repository already exists, skipping clone..."
fi

# Ensure scripts have execute permission
if [ -d "$SCRIPT_DIR" ]; then
    echo "Setting execute permissions on scripts..."
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
fi

docker run --rm \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --ipc=host \
    -e PMIX_MCA_gds=^ds21 \
    -v "$BASE_DIR":/tmp \
    -v "$BASE_DIR/cp2k_repo":/cp2k_source \
    -v "$SCRIPT_DIR":/scripts \
    $CONTAINER_IMAGE \
    bash -c "
        echo \"Using executable: $CP2K_EXECUTABLE\"
        echo \"Running benchmark with affinity scripts...\"
        
        # Ensure scripts have execute permission inside container
        chmod +x /scripts/*.sh 2>/dev/null || true
        
        # The container has CP2K installed via Spack with symlink at /opt/cp2k
        # Find the CP2K executable using the symlink
        CP2K_PATH=\$(which $CP2K_EXECUTABLE 2>/dev/null)
        if [ -z \"\$CP2K_PATH\" ] || [ ! -x \"\$CP2K_PATH\" ]; then
            echo \"ERROR: CP2K executable not found in PATH: $CP2K_EXECUTABLE\"
            echo \"Current PATH: \$PATH\"
            ls -la /opt/cp2k/bin/ 2>/dev/null || echo \"/opt/cp2k/bin not found\"
            exit 1
        fi
        echo \"Found CP2K at: \$CP2K_PATH\"
        
        # Run with affinity scripts
        # Enable g2g (GPU-to-GPU) for DBCSR
        mpirun \
            -x NUM_CPUS=$NUM_CPUS \
            -x NUM_GPUS=$NUM_GPUS \
            -x OMP_NUM_THREADS=$OMP_NUM_THREADS \
            -x DBCSR_USE_ACC_G2G=1 \
            --oversubscribe \
            -np $NUM_RANKS \
            --bind-to none \
            /scripts/set_cpu_affinity.sh \
            /scripts/set_gpu_affinity.sh \
            \$CP2K_PATH \
            -i $BENCHMARK_INPUT \
            -o $OUTPUT_FILE
        
        if [ \$? -eq 0 ]; then
            echo ''
            echo '=========================================='
            echo 'Benchmark completed successfully!'
            echo '=========================================='
            echo \"Output file: $OUTPUT_FILE\"
            echo ''
            echo 'FORCE_EVAL timing:'
            grep 'FORCE_EVAL' $OUTPUT_FILE || echo 'No FORCE_EVAL timing found'
            echo ''
            echo 'All CP2K timing lines:'
            grep 'CP2K             ' $OUTPUT_FILE || echo 'No timing information found'
            echo ''
            
            # Extract FOM: last time value from the last line matching 'CP2K             '
            FOM_LINE=\$(grep 'CP2K             ' $OUTPUT_FILE | tail -n 1)
            if [ -n \"\$FOM_LINE\" ]; then
                # Extract the last numeric value (time) from the line
                # This assumes the time is the last field/word in the line
                FOM=\$(echo \"\$FOM_LINE\" | awk '{print \$NF}')
                echo '=========================================='
                echo \"FOM (Figure of Merit): \$FOM seconds\"
                echo '=========================================='
            else
                echo 'Warning: Could not extract FOM from output file'
            fi
        else
            echo 'Benchmark failed!'
            exit 1
        fi
    "

echo ""
echo "Output file saved to: $BASE_DIR/H2O-DFT-LS-NREP2-16ranks.txt"
