#!/bin/bash
#
# Helpers shared by the Singularity run scripts. Mirror docker/scripts/
# but launch via `singularity exec --rocm` instead of `docker run`.

set -eu
set -o pipefail

RUN_COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SING_DIR="$(cd "${RUN_COMMON_SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${SING_DIR}/.." && pwd)"

SIF_IMAGE="${SIF_IMAGE:-${SING_DIR}/cp2k.sif}"
HOST_OUTPUT_ROOT="${HOST_OUTPUT_ROOT:-${SING_DIR}/outputs}"
mkdir -p "${HOST_OUTPUT_ROOT}"

# Put singularity on PATH; load a module if needed (override the module
# name with SINGULARITY_MODULE, e.g. SINGULARITY_MODULE=apptainer).
ensure_singularity() {
    if ! command -v singularity >/dev/null 2>&1; then
        module load "${SINGULARITY_MODULE:-singularity}" >/dev/null 2>&1 || true
    fi
    if ! command -v singularity >/dev/null 2>&1; then
        echo "ERROR: 'singularity' not found. Add it to PATH or set SINGULARITY_MODULE." >&2
        exit 1
    fi
}

# Clone CP2K on the host for benchmark inputs; echo the benchmark dir.
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

# bash snippet run inside the container: activate Spack, locate binaries,
# then eval the supplied launch command.
container_command() {
    local launch_cmd="$1"
    cat <<EOF
set -eu
set -o pipefail
ulimit -s unlimited || true
ulimit -c 0 || true

# Clear SLURM/PMI vars so in-container mpirun launches locally (the image
# has no srun); ranks are already fixed via -np on a single node.
for v in \$(env | grep -E '^(SLURM_|PMI_|PMIX_)' | cut -d= -f1); do unset "\$v"; done

source /opt/cp2k-build/spack_git/share/spack/setup-env.sh
spack env activate cp2k
spack load cp2k

CP2K_BIN=\$(command -v cp2k.psmp)
GPU_BIND_BIN=/opt/cp2k-build/shared/close.sh
echo "CP2K binary: \${CP2K_BIN}"
echo "GPU binder:  \${GPU_BIND_BIN}"

${launch_cmd}
EOF
}
