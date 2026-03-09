#!/bin/bash
#
# Run CP2K RPA benchmark (32-H2O) with two stages using ssitaram/cp2k:pr22 container
# Stage 1 (init): H2O-32-PBE-TZ.inp - 1 rank, 4 threads, 1 GPU
# Stage 2 (solver): H2O-32-RI-dRPA-TZ.inp - 16 ranks, 8 threads, 8 GPUs
#

set -e

CONTAINER_IMAGE="localhost/cp2k:latest"
CP2K_BRANCH="v2026.1"
CP2K_EXECUTABLE="cp2k.psmp"
BENCHMARK_DIR="/cp2k_source/benchmarks/QS_mp2_rpa/32-H2O"

# Stage 1: Init
INIT_INPUT="${BENCHMARK_DIR}/H2O-32-PBE-TZ.inp"
INIT_OUTPUT="/tmp/H2O-32-PBE-TZ-output.txt"
INIT_RANKS=1
INIT_THREADS=4
INIT_GPUS=1
INIT_CPUS=128

# Stage 2: Solver
SOLVER_INPUT="${BENCHMARK_DIR}/H2O-32-RI-dRPA-TZ.inp"
SOLVER_OUTPUT="/tmp/H2O-32-RI-dRPA-TZ-output.txt"
SOLVER_RANKS=16
SOLVER_THREADS=8
SOLVER_GPUS=8
SOLVER_CPUS=128

echo "=========================================="
echo "CP2K RPA Benchmark (32-H2O)"
echo "Container: $CONTAINER_IMAGE"
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

echo ""
echo "=========================================="
echo "STAGE 1: Init (H2O-32-PBE-TZ.inp)"
echo "Ranks: $INIT_RANKS, Threads: $INIT_THREADS, GPUs: $INIT_GPUS"
echo "=========================================="

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
        echo \"Running Init Stage...\"
        
        # Ensure scripts have execute permission inside container
        chmod +x /scripts/*.sh 2>/dev/null || true
        
        # Find the CP2K executable
        CP2K_PATH=\$(which $CP2K_EXECUTABLE 2>/dev/null)
        if [ -z \"\$CP2K_PATH\" ] || [ ! -x \"\$CP2K_PATH\" ]; then
            echo \"ERROR: CP2K executable not found in PATH: $CP2K_EXECUTABLE\"
            exit 1
        fi
        echo \"Found CP2K at: \$CP2K_PATH\"
        
        # Change to benchmark directory
        cd $BENCHMARK_DIR || exit 1
        echo \"Working directory: \$(pwd)\"
        
        # Run init stage with affinity scripts
        mpirun \
            -x NUM_CPUS=$INIT_CPUS \
            -x NUM_GPUS=$INIT_GPUS \
            -x OMP_NUM_THREADS=$INIT_THREADS \
            --oversubscribe \
            -np $INIT_RANKS \
            --bind-to none \
            /scripts/set_cpu_affinity.sh \
            /scripts/set_gpu_affinity.sh \
            \$CP2K_PATH \
            -i $INIT_INPUT \
            -o $INIT_OUTPUT
        
        if [ \$? -eq 0 ]; then
            echo ''
            echo '=========================================='
            echo 'Init Stage completed successfully!'
            echo '=========================================='
            echo 'FORCE_EVAL timing:'
            grep 'FORCE_EVAL' $INIT_OUTPUT || echo 'No FORCE_EVAL timing found'
            echo ''
            echo 'CP2K timing:'
            grep 'CP2K             ' $INIT_OUTPUT | tail -n 1 || echo 'No timing found'
            
            # Extract FOM
            FOM_LINE=\$(grep 'CP2K             ' $INIT_OUTPUT | tail -n 1)
            if [ -n \"\$FOM_LINE\" ]; then
                FOM=\$(echo \"\$FOM_LINE\" | awk '{print \$NF}')
                echo \"Init Stage FOM: \$FOM seconds\"
            fi
        else
            echo 'Init stage failed!'
            exit 1
        fi
    "

if [ $? -ne 0 ]; then
    echo "Init stage failed, aborting solver stage"
    exit 1
fi

echo ""
echo "=========================================="
echo "STAGE 2: Solver (H2O-32-RI-dRPA-TZ.inp)"
echo "Ranks: $SOLVER_RANKS, Threads: $SOLVER_THREADS, GPUs: $SOLVER_GPUS"
echo "=========================================="

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
        echo \"Running Solver Stage...\"
        
        # Ensure scripts have execute permission inside container
        chmod +x /scripts/*.sh 2>/dev/null || true
        
        # Find the CP2K executable
        CP2K_PATH=\$(which $CP2K_EXECUTABLE 2>/dev/null)
        if [ -z \"\$CP2K_PATH\" ] || [ ! -x \"\$CP2K_PATH\" ]; then
            echo \"ERROR: CP2K executable not found in PATH: $CP2K_EXECUTABLE\"
            exit 1
        fi
        echo \"Found CP2K at: \$CP2K_PATH\"
        
        # Change to benchmark directory
        cd $BENCHMARK_DIR || exit 1
        echo \"Working directory: \$(pwd)\"
        
        # Run solver stage with affinity scripts
        # Enable g2g (GPU-to-GPU) for DBCSR
        mpirun \
            -x NUM_CPUS=$SOLVER_CPUS \
            -x NUM_GPUS=$SOLVER_GPUS \
            -x OMP_NUM_THREADS=$SOLVER_THREADS \
            -x DBCSR_USE_ACC_G2G=1 \
            --oversubscribe \
            -np $SOLVER_RANKS \
            --bind-to none \
            /scripts/set_cpu_affinity.sh \
            /scripts/set_gpu_affinity.sh \
            \$CP2K_PATH \
            -i $SOLVER_INPUT \
            -o $SOLVER_OUTPUT
        
        if [ \$? -eq 0 ]; then
            echo ''
            echo '=========================================='
            echo 'Solver Stage completed successfully!'
            echo '=========================================='
            echo 'FORCE_EVAL timing:'
            grep 'FORCE_EVAL' $SOLVER_OUTPUT || echo 'No FORCE_EVAL timing found'
            echo ''
            echo 'CP2K timing:'
            grep 'CP2K             ' $SOLVER_OUTPUT | tail -n 1 || echo 'No timing found'
            
            # Extract FOM
            FOM_LINE=\$(grep 'CP2K             ' $SOLVER_OUTPUT | tail -n 1)
            if [ -n \"\$FOM_LINE\" ]; then
                FOM=\$(echo \"\$FOM_LINE\" | awk '{print \$NF}')
                echo \"Solver Stage FOM: \$FOM seconds\"
            fi
        else
            echo 'Solver stage failed!'
            exit 1
        fi
    "

echo ""
echo "=========================================="
echo "RPA Benchmark Complete!"
echo "=========================================="
echo "Init output: $BASE_DIR/H2O-32-PBE-TZ-output.txt"
echo "Solver output: $BASE_DIR/H2O-32-RI-dRPA-TZ-output.txt"
echo ""
echo "Summary:"
echo "--------"
echo "Init Stage:"
grep 'FORCE_EVAL' "$BASE_DIR/H2O-32-PBE-TZ-output.txt" 2>/dev/null || echo "  FORCE_EVAL: Not available"
grep 'CP2K             ' "$BASE_DIR/H2O-32-PBE-TZ-output.txt" 2>/dev/null | tail -n 1 | awk '{print "  CP2K FOM: " $NF " seconds"}' || echo "  FOM: Not available"
echo ""
echo "Solver Stage:"
grep 'FORCE_EVAL' "$BASE_DIR/H2O-32-RI-dRPA-TZ-output.txt" 2>/dev/null || echo "  FORCE_EVAL: Not available"
grep 'CP2K             ' "$BASE_DIR/H2O-32-RI-dRPA-TZ-output.txt" 2>/dev/null | tail -n 1 | awk '{print "  CP2K FOM: " $NF " seconds"}' || echo "  FOM: Not available"

