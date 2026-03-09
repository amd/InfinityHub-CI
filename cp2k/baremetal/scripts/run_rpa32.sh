#!/bin/bash
#
# Run CP2K RPA benchmark (32-H2O) with two stages on baremetal
# Stage 1 (init): H2O-32-PBE-TZ.inp - 1 rank, 4 threads, 1 GPU
# Stage 2 (solver): H2O-32-RI-dRPA-TZ.inp - 16 ranks, 8 threads, 8 GPUs
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAREMETAL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${BAREMETAL_DIR}/.." && pwd)"

CP2K_BRANCH="v2026.1"
CP2K_EXECUTABLE="cp2k.psmp"
BENCHMARK_DIR="${PROJECT_ROOT}/cp2k_repo/benchmarks/QS_mp2_rpa/32-H2O"

# Stage 1: Init
INIT_INPUT="${BENCHMARK_DIR}/H2O-32-PBE-TZ.inp"
INIT_OUTPUT="${BAREMETAL_DIR}/H2O-32-PBE-TZ-output.txt"
INIT_RANKS=1
INIT_THREADS=4
INIT_GPUS=1
INIT_CPUS=128

# Stage 2: Solver
SOLVER_INPUT="${BENCHMARK_DIR}/H2O-32-RI-dRPA-TZ.inp"
SOLVER_OUTPUT="${BAREMETAL_DIR}/H2O-32-RI-dRPA-TZ-output.txt"
SOLVER_RANKS=16
SOLVER_THREADS=8
SOLVER_GPUS=8
SOLVER_CPUS=128

echo "=========================================="
echo "CP2K RPA Benchmark (32-H2O) - Baremetal"
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

# Ensure benchmark directory exists
if [ ! -d "$BENCHMARK_DIR" ]; then
    echo "ERROR: Benchmark directory not found: $BENCHMARK_DIR"
    exit 1
fi

echo ""
echo "=========================================="
echo "STAGE 1: Init (H2O-32-PBE-TZ.inp)"
echo "Ranks: $INIT_RANKS, Threads: $INIT_THREADS, GPUs: $INIT_GPUS"
echo "=========================================="

# Change to benchmark directory
cd "$BENCHMARK_DIR" || exit 1
echo "Working directory: $(pwd)"

# Run init stage with affinity scripts
# Use UCX with shared memory and ROCm transports
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
    -x NUM_CPUS=$INIT_CPUS \
    -x NUM_GPUS=$INIT_GPUS \
    -x OMP_NUM_THREADS=$INIT_THREADS \
    --oversubscribe \
    -np $INIT_RANKS \
    --bind-to none \
    "${SCRIPT_DIR}/set_cpu_affinity.sh" \
    "${SCRIPT_DIR}/set_gpu_affinity.sh" \
    "$CP2K_PATH" \
    -i "$INIT_INPUT" \
    -o "$INIT_OUTPUT"

if [ $? -eq 0 ]; then
    echo ''
    echo '=========================================='
    echo 'Init Stage completed successfully!'
    echo '=========================================='
    echo 'FORCE_EVAL timing:'
    grep 'FORCE_EVAL' "$INIT_OUTPUT" || echo 'No FORCE_EVAL timing found'
    echo ''
    echo 'CP2K timing:'
    grep 'CP2K             ' "$INIT_OUTPUT" | tail -n 1 || echo 'No timing found'
    
    # Extract FOM
    FOM_LINE=$(grep 'CP2K             ' "$INIT_OUTPUT" | tail -n 1)
    if [ -n "$FOM_LINE" ]; then
        FOM=$(echo "$FOM_LINE" | awk '{print $NF}')
        echo "Init Stage FOM: $FOM seconds"
    fi
else
    echo 'Init stage failed!'
    exit 1
fi

echo ""
echo "=========================================="
echo "STAGE 2: Solver (H2O-32-RI-dRPA-TZ.inp)"
echo "Ranks: $SOLVER_RANKS, Threads: $SOLVER_THREADS, GPUs: $SOLVER_GPUS"
echo "=========================================="

# Run solver stage with affinity scripts
# Use UCX with shared memory and ROCm transports (disable InfiniBand)
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
    --mca btl ^openib \
    --mca pml_base_verbose 0 \
    -x NUM_CPUS=$SOLVER_CPUS \
    -x NUM_GPUS=$SOLVER_GPUS \
    -x OMP_NUM_THREADS=$SOLVER_THREADS \
    -x DBCSR_USE_ACC_G2G=1 \
    --oversubscribe \
    -np $SOLVER_RANKS \
    --bind-to none \
    "${SCRIPT_DIR}/set_cpu_affinity.sh" \
    "${SCRIPT_DIR}/set_gpu_affinity.sh" \
    "$CP2K_PATH" \
    -i "$SOLVER_INPUT" \
    -o "$SOLVER_OUTPUT"

if [ $? -eq 0 ]; then
    echo ''
    echo '=========================================='
    echo 'Solver Stage completed successfully!'
    echo '=========================================='
    echo 'FORCE_EVAL timing:'
    grep 'FORCE_EVAL' "$SOLVER_OUTPUT" || echo 'No FORCE_EVAL timing found'
    echo ''
    echo 'CP2K timing:'
    grep 'CP2K             ' "$SOLVER_OUTPUT" | tail -n 1 || echo 'No timing found'
    
    # Extract FOM
    FOM_LINE=$(grep 'CP2K             ' "$SOLVER_OUTPUT" | tail -n 1)
    if [ -n "$FOM_LINE" ]; then
        FOM=$(echo "$FOM_LINE" | awk '{print $NF}')
        echo "Solver Stage FOM: $FOM seconds"
    fi
else
    echo 'Solver stage failed!'
    exit 1
fi

echo ""
echo "=========================================="
echo "RPA Benchmark Complete!"
echo "=========================================="
echo "Init output: $INIT_OUTPUT"
echo "Solver output: $SOLVER_OUTPUT"
echo ""
echo "Summary:"
echo "--------"
echo "Init Stage:"
grep 'FORCE_EVAL' "$INIT_OUTPUT" 2>/dev/null || echo "  FORCE_EVAL: Not available"
grep 'CP2K             ' "$INIT_OUTPUT" 2>/dev/null | tail -n 1 | awk '{print "  CP2K FOM: " $NF " seconds"}' || echo "  FOM: Not available"
echo ""
echo "Solver Stage:"
grep 'FORCE_EVAL' "$SOLVER_OUTPUT" 2>/dev/null || echo "  FORCE_EVAL: Not available"
grep 'CP2K             ' "$SOLVER_OUTPUT" 2>/dev/null | tail -n 1 | awk '{print "  CP2K FOM: " $NF " seconds"}' || echo "  FOM: Not available"
