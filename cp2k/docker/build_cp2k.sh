#!/bin/bash
#
# Build the CP2K Docker image.
#
# The image is built from the repository root so that ./shared/ is part of
# the build context (the Dockerfile COPYs shared/ into the image and runs
# shared/cp2k_build.sh inside).
#
# Usage:
#   ./build_cp2k.sh [--clean] [--no-cache] [--cache-from IMAGE]
#
# Build target/version knobs are forwarded to the Dockerfile via build args
# and default to an MI350X recipe (gfx950 / zen5 / ROCm 7.2). Override
# them via environment variables before invoking this script:
#
#   GPU_ARCH=gfx942 CPU_ARCH=zen3 ROCM_VERSION=7.0.0 ./build_cp2k.sh

set -eu
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

IMAGE_NAME="${IMAGE_NAME:-cp2k}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
BASE_IMAGE="${BASE_IMAGE:-rocm/dev-ubuntu-24.04:7.2-complete}"

GPU_ARCH="${GPU_ARCH:-gfx950}"
CPU_ARCH="${CPU_ARCH:-zen5}"
ROCM_VERSION="${ROCM_VERSION:-7.2.0}"
ROCM_PATH="${ROCM_PATH:-/opt/rocm-${ROCM_VERSION}}"
GCC_VERSION="${GCC_VERSION:-14.3.0}"
SPACK_BRANCH="${SPACK_BRANCH:-v1.1.1}"
SPACK_PACKAGES_TAG="${SPACK_PACKAGES_TAG:-v2026.03.0}"
BUILD_JOBS="${BUILD_JOBS:-32}"

BUILD_LOG="${SCRIPT_DIR}/build.log"

CLEAN=false
NO_CACHE=false
CACHE_FROM=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)       CLEAN=true; shift ;;
        --no-cache)    NO_CACHE=true; shift ;;
        --cache-from)  CACHE_FROM="$2"; shift 2 ;;
        --help|-h)
            sed -n '2,/^set -eu/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--clean] [--no-cache] [--cache-from IMAGE]" >&2
            exit 1
            ;;
    esac
done

if [ "${CLEAN}" = true ]; then
    echo "=== Cleaning up old containers and images ==="
    docker ps -a --filter "ancestor=${IMAGE_NAME}:${IMAGE_TAG}" --format "{{.ID}}" \
        | xargs -r docker rm -f 2>/dev/null || true
    OLD_IMAGES=$(docker images "${IMAGE_NAME}" --format "{{.ID}}" | tail -n +2)
    if [ -n "${OLD_IMAGES}" ]; then
        echo "${OLD_IMAGES}" | xargs -r docker rmi -f 2>/dev/null || true
    fi
fi

cat <<EOF
==========================================
CP2K Docker build
  Image:              ${IMAGE_NAME}:${IMAGE_TAG}
  Base image:         ${BASE_IMAGE}
  GPU target:         ${GPU_ARCH}
  CPU target:         ${CPU_ARCH}
  ROCm version:       ${ROCM_VERSION}
  ROCm path:          ${ROCM_PATH}
  GCC version:        ${GCC_VERSION}
  Spack:              ${SPACK_BRANCH}
  spack-packages tag: ${SPACK_PACKAGES_TAG}
  Build jobs:         ${BUILD_JOBS}
  Build context:      ${REPO_ROOT}
==========================================
EOF

BUILD_ARGS=(
    --tag "${IMAGE_NAME}:${IMAGE_TAG}"
    --file "${SCRIPT_DIR}/Dockerfile"
    --build-arg "IMAGE=${BASE_IMAGE}"
    --build-arg "GPU_ARCH=${GPU_ARCH}"
    --build-arg "CPU_ARCH=${CPU_ARCH}"
    --build-arg "ROCM_VERSION=${ROCM_VERSION}"
    --build-arg "ROCM_PATH=${ROCM_PATH}"
    --build-arg "GCC_VERSION=${GCC_VERSION}"
    --build-arg "SPACK_BRANCH=${SPACK_BRANCH}"
    --build-arg "SPACK_PACKAGES_TAG=${SPACK_PACKAGES_TAG}"
    --build-arg "BUILD_JOBS=${BUILD_JOBS}"
)
[ -n "${CACHE_FROM}" ] && BUILD_ARGS+=(--cache-from "${CACHE_FROM}")
[ "${NO_CACHE}" = true ] && BUILD_ARGS+=(--no-cache)

export DOCKER_BUILDKIT=1

echo "Starting build at $(date)"
if docker build "${BUILD_ARGS[@]}" "${REPO_ROOT}" 2>&1 | tee "${BUILD_LOG}"; then
    echo
    echo "=== Build completed at $(date) ==="
    docker images "${IMAGE_NAME}:${IMAGE_TAG}"
else
    echo
    echo "=== Build failed; see ${BUILD_LOG} ===" >&2
    exit 1
fi
