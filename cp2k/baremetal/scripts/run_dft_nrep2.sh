#!/bin/bash
#
# Run CP2K DFT benchmark with 16 MPI ranks on baremetal
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAREMETAL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${BAREMETAL_DIR}/.." && pwd)"

NUM_RANKS=16
NUM_GPUS=${NUM_GPUS:-8}
NUM_CPUS=${NUM_CPUS:-128}
OMP_NUM_THREADS=${OMP_NUM_THREADS:-4}
CP2K_BRANCH="v2026.1"
BENCHMARK_INPUT="${PROJECT_ROOT}/cp2k_repo/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp"
OUTPUT_FILE="${BAREMETAL_DIR}/H2O-DFT-LS-NREP2-16ranks.txt"
CP2K_EXECUTABLE="cp2k.psmp"

echo "=========================================="
echo "Running CP2K DFT Benchmark - Baremetal"
echo "MPI Ranks: $NUM_RANKS"
echo "OpenMP Threads per rank: $OMP_NUM_THREADS"
echo "Executable: $CP2K_EXECUTABLE"
echo "CP2K Branch: $CP2K_BRANCH"
echo "=========================================="

# Source Spack environment
SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
if [ -f "${SPACK_ROOT}/share/spack/setup-env.sh" ]; then
    source "${SPACK_ROOT}/share/spack/setup-env.sh"
else
    echo "ERROR: Spack not found at ${SPACK_ROOT}/share/spack/setup-env.sh"
    echo "Please set SPACK_ROOT environment variable or ensure Spack is installed at ~/spack"
    exit 1
fi

# Activate Spack environment
SPACK_ENV_DIR="${PROJECT_ROOT}/docker/cp2k_environment"
if [ ! -d "$SPACK_ENV_DIR" ]; then
    echo "ERROR: Spack environment directory not found: $SPACK_ENV_DIR"
    exit 1
fi

cd "$SPACK_ENV_DIR" || exit 1
# Activate Spack environment (suppress warnings but keep activation)
spack env activate cp2k-baremetal 2>&1 | grep -v "Warning: package repository" || true
# Ensure environment is actually activated
eval $(spack env activate --sh cp2k-baremetal 2>&1 | grep -v "Warning: package repository")

# Clone CP2K repository if not already present
if [ ! -d "${PROJECT_ROOT}/cp2k_repo" ]; then
    echo "Cloning CP2K repository (branch ${CP2K_BRANCH})..."
    cd "$PROJECT_ROOT" || exit 1
    git clone --recursive -b ${CP2K_BRANCH} https://github.com/cp2k/cp2k.git cp2k_repo
else
    echo "CP2K repository already exists, skipping clone..."
fi

# Ensure scripts have execute permission
if [ -d "${SCRIPT_DIR}" ]; then
    echo "Setting execute permissions on scripts..."
    chmod +x "${SCRIPT_DIR}"/*.sh 2>/dev/null || true
fi

# Find the CP2K executable
CP2K_PATH=$(which $CP2K_EXECUTABLE 2>/dev/null)
if [ -z "$CP2K_PATH" ] || [ ! -x "$CP2K_PATH" ]; then
    echo "ERROR: CP2K executable not found in PATH: $CP2K_EXECUTABLE"
    echo "Current PATH: $PATH"
    exit 1
fi
echo "Found CP2K at: $CP2K_PATH"

# Ensure benchmark input file exists
if [ ! -f "$BENCHMARK_INPUT" ]; then
    echo "ERROR: Benchmark input file not found: $BENCHMARK_INPUT"
    exit 1
fi

echo "Using executable: $CP2K_EXECUTABLE"
echo "Running benchmark with affinity scripts..."

# Change to benchmark directory
BENCHMARK_DIR=$(dirname "$BENCHMARK_INPUT")
cd "$BENCHMARK_DIR" || exit 1
echo "Working directory: $(pwd)"

# Run with affinity scripts
# Use UCX with shared memory and ROCm transports
# Enable g2g (GPU-to-GPU) for DBCSR
mpirun \
    -x UCX_TLS=sm,self,rocm \
    -x UCX_PROTO_ENABLE=n \
    -x UCX_ROCM_COPY_LAT=2e-6 \
    -x UCX_ROCM_IPC_MIN_ZCOPY=4096 \
    --mca pml ucx \
    --mca osc ucx \
    -x UCX_MM_SEG_SIZE=60k \
    -x UCX_ROCM_COPY_H2D_THRESH=256 \
    --mca coll_ucc_enable 1 \
    --mca coll_ucc_priority 100 \
    -x NUM_CPUS=$NUM_CPUS \
    -x NUM_GPUS=$NUM_GPUS \
    -x OMP_NUM_THREADS=$OMP_NUM_THREADS \
    -x DBCSR_USE_ACC_G2G=1 \
    --oversubscribe \
    -np $NUM_RANKS \
    --bind-to none \
    "${SCRIPT_DIR}/set_cpu_affinity.sh" \
    "${SCRIPT_DIR}/set_gpu_affinity.sh" \
    "$CP2K_PATH" \
    -i "$BENCHMARK_INPUT" \
    -o "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo ''
    echo '=========================================='
    echo 'Benchmark completed successfully!'
    echo '=========================================='
    echo "Output file: $OUTPUT_FILE"
    echo ''
    echo 'FORCE_EVAL timing:'
    grep 'FORCE_EVAL' "$OUTPUT_FILE" || echo 'No FORCE_EVAL timing found'
    echo ''
    echo 'All CP2K timing lines:'
    grep 'CP2K             ' "$OUTPUT_FILE" || echo 'No timing information found'
    echo ''
    
    # Extract FOM: last time value from the last line matching 'CP2K             '
    FOM_LINE=$(grep 'CP2K             ' "$OUTPUT_FILE" | tail -n 1)
    if [ -n "$FOM_LINE" ]; then
        # Extract the last numeric value (time) from the line
        # This assumes the time is the last field/word in the line
        FOM=$(echo "$FOM_LINE" | awk '{print $NF}')
        echo '=========================================='
        echo "FOM (Figure of Merit): $FOM seconds"
        echo '=========================================='
    else
        echo 'Warning: Could not extract FOM from output file'
    fi
else
    echo 'Benchmark failed!'
    exit 1
fi

echo ""
echo "Output file saved to: $OUTPUT_FILE"
