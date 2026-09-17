#!/bin/bash
#
# Helpers shared by the Docker run scripts.
#
# The docker scripts mirror the baremetal scripts under
# baremetal/scripts/ as closely as possible: same .run filenames, same
# SBATCH directives, same lowercase topology variables, same EXPNAME and
# output directory layout. The only essential difference is that the
# benchmark mpirun is wrapped in `docker run` against the cp2k image.
#
# This file provides the docker counterparts to baremetal's _run_common.sh
# helpers:
#
#   cp2k_benchmark_dir <rel>   - clone CP2K source on the host so we can
#                                bind-mount its benchmark inputs into the
#                                container (same signature as baremetal)
#   report_fom <output_file>   - extract CP2K timing FOM from the output
#                                file (same signature as baremetal)
#   docker_run_args            - common docker run flags (ROCm + IPC)
#   container_command <launch> - bash snippet that activates the Spack
#                                environment inside the container, locates
#                                cp2k.psmp + close.sh, then evals <launch>
#                                (replaces baremetal's activate_cp2k +
#                                require_cp2k_bin, which run on the host)

set -eu
set -o pipefail

RUN_COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(cd "${RUN_COMMON_SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="$(cd "${DOCKER_DIR}/.." && pwd)"

CONTAINER_IMAGE="${CONTAINER_IMAGE:-cp2k:latest}"
HOST_OUTPUT_ROOT="${HOST_OUTPUT_ROOT:-${DOCKER_DIR}/outputs}"
mkdir -p "${HOST_OUTPUT_ROOT}"

# ---- CP2K benchmark inputs (host side) ---------------------------------
# Clones the CP2K source tree into ${PROJECT_ROOT}/cp2k_repo if needed and
# echoes the absolute path to the benchmark directory passed as $1. This
# is host-side because the docker scripts bind-mount the directory into
# the container at /benchmark.
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

# ---- Print FOM line(s) from a CP2K output file -------------------------
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

# ---- Common docker run flags -------------------------------------------
# ROCm device passthrough, IPC for GPU peer access, host output mount.
docker_run_args() {
    cat <<EOF
--rm
--device=/dev/kfd
--device=/dev/dri
--security-opt=seccomp=unconfined
--ipc=host
--shm-size=16g
--cap-add=SYS_PTRACE
-e PMIX_MCA_gds=^ds21
-v ${HOST_OUTPUT_ROOT}:/outputs
EOF
}

# ---- Container-side activation snippet ---------------------------------
# Build the bash command that runs inside the container. Activates the
# Spack environment, locates cp2k.psmp + close.sh, then execs the supplied
# launch command. Docker analogue of activate_cp2k + require_cp2k_bin in
# the baremetal helpers.
container_command() {
    local launch_cmd="$1"
    cat <<EOF
set -eu
set -o pipefail

ulimit -s unlimited || true
ulimit -c 0 || true

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
