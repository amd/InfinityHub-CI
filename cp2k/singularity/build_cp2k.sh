#!/bin/bash
#
# Build the CP2K Singularity image (cp2k.sif).
#
# Run from the repo root so shared/ is in the build context:
#   ./singularity/build_cp2k.sh
#
# Override defaults (MI350X/MI355X gfx950 / zen5 / ROCm 7.2) via env vars:
#   GPU_ARCH=gfx942 CPU_ARCH=zen3 ROCM_VERSION=7.0.0 ./singularity/build_cp2k.sh

set -eu
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DEF="${SCRIPT_DIR}/cp2k.def"
SIF="${SIF:-${SCRIPT_DIR}/cp2k.sif}"

BASE_IMAGE="${BASE_IMAGE:-rocm/dev-ubuntu-24.04:7.2-complete}"
GPU_ARCH="${GPU_ARCH:-gfx950}"
CPU_ARCH="${CPU_ARCH:-zen5}"
ROCM_VERSION="${ROCM_VERSION:-7.2.0}"
ROCM_PATH="${ROCM_PATH:-/opt/rocm-${ROCM_VERSION}}"
GCC_VERSION="${GCC_VERSION:-14.3.0}"
SPACK_BRANCH="${SPACK_BRANCH:-v1.1.1}"
SPACK_PACKAGES_TAG="${SPACK_PACKAGES_TAG:-v2026.03.0}"
BUILD_JOBS="${BUILD_JOBS:-32}"

# Unprivileged builds need fakeroot; disable with FAKEROOT=0.
FAKEROOT_FLAG="--fakeroot"
[ "${FAKEROOT:-1}" = "0" ] && FAKEROOT_FLAG=""

cd "${REPO_ROOT}"
singularity build ${FAKEROOT_FLAG} \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    --build-arg "GPU_ARCH=${GPU_ARCH}" \
    --build-arg "CPU_ARCH=${CPU_ARCH}" \
    --build-arg "ROCM_VERSION=${ROCM_VERSION}" \
    --build-arg "ROCM_PATH=${ROCM_PATH}" \
    --build-arg "GCC_VERSION=${GCC_VERSION}" \
    --build-arg "SPACK_BRANCH=${SPACK_BRANCH}" \
    --build-arg "SPACK_PACKAGES_TAG=${SPACK_PACKAGES_TAG}" \
    --build-arg "BUILD_JOBS=${BUILD_JOBS}" \
    "${SIF}" "${DEF}"

echo "Built ${SIF}"
