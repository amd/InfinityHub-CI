#!/bin/bash
#
# Helpers shared by the baremetal run scripts.
#
# Sources Spack, activates the cp2k environment, prepares CP2K binary path,
# benchmark inputs, OpenMPI/UCX env vars, and exports an RPA-friendly
# default mpirun layout. Sourced (not executed) by the launcher scripts.

set -eu
set -o pipefail

# ---- Paths --------------------------------------------------------------
RUN_COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAREMETAL_DIR="$(cd "${RUN_COMMON_SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${BAREMETAL_DIR}/.." && pwd)"
SHARED_DIR="${PROJECT_ROOT}/shared"

# Where the build script put everything (matches baremetal/build_cp2k.sh)
BUILD_ROOT="${BUILD_ROOT:-${BAREMETAL_DIR}/cp2k-baremetal}"
SPACK_GIT_DIR="${SPACK_GIT_DIR:-${BUILD_ROOT}/spack_git}"

# Helper binaries
GPU_SMI_BIN="${GPU_SMI_BIN:-/usr/bin/rocm-smi}"
GPU_BIND_BIN="${GPU_BIND_BIN:-${SHARED_DIR}/close.sh}"

# ---- Activate Spack environment ----------------------------------------
activate_cp2k() {
    if [ ! -f "${SPACK_GIT_DIR}/share/spack/setup-env.sh" ]; then
        echo "ERROR: Spack not found at ${SPACK_GIT_DIR}" >&2
        echo "       Run baremetal/build_cp2k.sh first or set BUILD_ROOT." >&2
        return 1
    fi
    # shellcheck disable=SC1091
    source "${SPACK_GIT_DIR}/share/spack/setup-env.sh"
    spack env activate cp2k
    spack load cp2k
}

# ---- CP2K benchmark inputs ---------------------------------------------
# Clones the CP2K source tree into ${PROJECT_ROOT}/cp2k_repo if needed and
# echoes the absolute path to the benchmark directory passed as $1.
cp2k_benchmark_dir() {
    local rel="$1"
    local cp2k_branch="${CP2K_BRANCH:-v2026.1}"
    if [ ! -d "${PROJECT_ROOT}/cp2k_repo" ]; then
        echo "INFO: Cloning CP2K (${cp2k_branch}) into ${PROJECT_ROOT}/cp2k_repo" >&2
        git clone --recursive -b "${cp2k_branch}" \
            https://github.com/cp2k/cp2k.git \
            "${PROJECT_ROOT}/cp2k_repo" >&2
    fi
    echo "${PROJECT_ROOT}/cp2k_repo/benchmarks/${rel}"
}

# ---- Default OpenMPI / UCX runtime tuning -------------------------------
# Sets OpenMP threading, ROCm / HSA, and UCX defaults that the launcher
# scripts rely on, and exports OMPI_MCA_mca_base_env_list so mpirun
# forwards them to all ranks. Per-benchmark vars (e.g. DBCSR_USE_ACC_G2G
# for the DFT benchmark) are added explicitly via mpirun -x in the
# relevant launcher script.
export_runtime_env() {
    export OMP_PROC_BIND="${OMP_PROC_BIND:-spread}"
    export OMP_PLACES="${OMP_PLACES:-threads}"
    export OMP_WAIT_POLICY="${OMP_WAIT_POLICY:-active}"
    export OMP_STACKSIZE="${OMP_STACKSIZE:-256M}"

    export HSA_ENABLE_SDMA="${HSA_ENABLE_SDMA:-0}"
    export HSA_ENABLE_IPC_MODE_LEGACY="${HSA_ENABLE_IPC_MODE_LEGACY:-1}"
    export HIP_MEM_POOL_SUPPORT="${HIP_MEM_POOL_SUPPORT:-1}"

    export OMPI_MCA_pml="${OMPI_MCA_pml:-ucx}"
    export OMPI_MCA_osc="${OMPI_MCA_osc:-ucx}"
    export OMPI_MCA_coll_ucc_enable="${OMPI_MCA_coll_ucc_enable:-1}"
    export OMPI_MCA_coll_ucc_priority="${OMPI_MCA_coll_ucc_priority:-100}"

    export UCX_TLS="${UCX_TLS:-self,sm,rocm_copy,rocm_ipc,ud_x}"
    export UCX_HANDLE_ERRORS="${UCX_HANDLE_ERRORS:-bt}"
    export UCX_MAX_RNDV_RAILS="${UCX_MAX_RNDV_RAILS:-1}"

    # Forward these env vars from mpirun to spawned ranks. Per-benchmark vars
    # (e.g. DBCSR_USE_ACC_G2G for the DFT benchmark) are added explicitly via
    # mpirun -x in the relevant launcher script.
    export OMPI_MCA_mca_base_env_list="OMP_PROC_BIND;OMP_PLACES;OMP_NUM_THREADS;OMP_STACKSIZE;HSA_ENABLE_SDMA;HSA_ENABLE_IPC_MODE_LEGACY;HIP_MEM_POOL_SUPPORT;UCX_TLS;UCX_HANDLE_ERRORS;UCX_MAX_RNDV_RAILS;ROCM_PATH;HIP_PLATFORM;HIP_DEVICE_LIB_PATH"

    ulimit -s unlimited || true
    ulimit -c 0 || true
}

# ---- Locate cp2k.psmp ---------------------------------------------------
require_cp2k_bin() {
    local bin="${CP2K_BIN_BASENAME:-cp2k.psmp}"
    local path
    path=$(command -v "${bin}" || true)
    if [ -z "${path}" ] || [ ! -x "${path}" ]; then
        echo "ERROR: ${bin} not found in PATH after activating the Spack env." >&2
        return 1
    fi
    echo "${path}"
}

# ---- Print FOM line(s) from a CP2K output file --------------------------
report_fom() {
    local out="$1"
    echo
    echo "FORCE_EVAL timing:"
    grep 'FORCE_EVAL' "${out}" 2>/dev/null || echo "  (none found)"
    echo
    echo "CP2K timing:"
    grep 'CP2K             ' "${out}" 2>/dev/null | tail -n 1 || echo "  (none found)"
    local last
    last=$(grep 'CP2K             ' "${out}" 2>/dev/null | tail -n 1 || true)
    if [ -n "${last}" ]; then
        echo
        echo "FOM: $(echo "${last}" | awk '{print $NF}') seconds"
    fi
}
