#!/bin/bash
#
# Baremetal entry point for the shared CP2K Spack build.
#
# This script is a thin wrapper around ../shared/cp2k_build.sh that defaults
# the build root to ./cp2k-baremetal so the entire Spack tree, install tree,
# and environments live under a single self-contained directory.
#
# All configuration is done through environment variables (see
# shared/cp2k_build.sh for the full list). The most common ones:
#
#   CPU_ARCH       Spack target microarch                 [zen5]
#   GPU_ARCH       AMD GPU target                         [gfx950]
#   ROCM_VERSION   ROCm version reported to Spack         [7.2.0]
#   ROCM_PATH      Path to the ROCm install               [/opt/rocm-${ROCM_VERSION}]
#   BUILD_ROOT     Where to put spack_git, install, etc.  [./cp2k-baremetal]
#   BUILD_JOBS     spack install -j                       [32]
#
# Examples:
#
#   # Default (MI350X / Zen5 / ROCm 7.2):
#   ./build_cp2k.sh
#
#   # MI300X on Zen3:
#   GPU_ARCH=gfx942 CPU_ARCH=zen3 ROCM_VERSION=7.0.0 ./build_cp2k.sh
#
#   # Custom install location:
#   BUILD_ROOT=/opt/cp2k-baremetal ./build_cp2k.sh

set -eu
set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SHARED_DIR=$(cd "${SCRIPT_DIR}/../shared" && pwd)

export BUILD_ROOT="${BUILD_ROOT:-${PWD}/cp2k-baremetal}"
mkdir -p "${BUILD_ROOT}"

echo "Baremetal CP2K build"
echo "  Shared script: ${SHARED_DIR}/cp2k_build.sh"
echo "  Build root:    ${BUILD_ROOT}"

exec "${SHARED_DIR}/cp2k_build.sh" "$@"
