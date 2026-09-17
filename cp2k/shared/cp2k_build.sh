#!/bin/bash
#
# Build CP2K with ROCm support using Spack.
#
# This script is the single source of truth for the build recipe and is used
# by the baremetal flow (baremetal/build_cp2k.sh), the Docker flow
# (docker/Dockerfile), and the Singularity flow (singularity/cp2k.def). It
# pins Spack and the spack-packages repo to known
# tags, applies a small upstream patch to add AMD MI350 (gfx950) support to
# the CP2K Spack package, generates a Spack environment, and builds CP2K.
#
# Behaviour can be tuned via environment variables (with sensible defaults
# for an MI350X / Zen5 / ROCm 7.2 host):
#
#   SPACK_BRANCH         git branch/tag of spack/spack          [v1.1.1]
#   SPACK_PACKAGES_TAG   git tag of spack/spack-packages        [v2026.03.0]
#   GCC_VERSION          GCC built with Spack and used as       [14.3.0]
#                        the CP2K compiler
#   CPU_ARCH             Spack target= microarch                [zen5]
#   GPU_ARCH             AMD GPU target (amdgpu_target=...)     [gfx950]
#   ROCM_VERSION         ROCm version reported to Spack         [7.2.0]
#   ROCM_PATH            Filesystem path to the ROCm install    [/opt/rocm-${ROCM_VERSION}]
#   BUILD_ROOT           Where Spack tree, install tree,        [script dir]
#                        environments etc. live
#   BUILD_JOBS           spack install -j                       [32]
#   SPACK_FETCH_JOBS     spack install -p                       [4]
#
# Defaults target an MI350X / Zen5 / ROCm 7.2 single-node host.

set -eu
set -o pipefail

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

SPACK_BRANCH="${SPACK_BRANCH:-v1.1.1}"
SPACK_PACKAGES_TAG="${SPACK_PACKAGES_TAG:-v2026.03.0}"
GCC_VERSION="${GCC_VERSION:-14.3.0}"
CPU_ARCH="${CPU_ARCH:-zen5}"
GPU_ARCH="${GPU_ARCH:-gfx950}"
ROCM_VERSION="${ROCM_VERSION:-7.2.0}"
ROCM_PATH="${ROCM_PATH:-/opt/rocm-${ROCM_VERSION}}"
BUILD_ROOT="${BUILD_ROOT:-${SCRIPT_DIR}}"
BUILD_JOBS="${BUILD_JOBS:-32}"
SPACK_FETCH_JOBS="${SPACK_FETCH_JOBS:-4}"

SPACK_GIT_DIR="${BUILD_ROOT}/spack_git"
SPACK_PACKAGES_GIT_DIR="spack-packages_git"

cat <<EOF
============================================================================
  CP2K Spack Build
============================================================================
  Script dir:           ${SCRIPT_DIR}
  Build root:           ${BUILD_ROOT}
  Spack branch:         ${SPACK_BRANCH}
  spack-packages tag:   ${SPACK_PACKAGES_TAG}
  GCC version:          ${GCC_VERSION}
  CPU target:           ${CPU_ARCH}
  GPU target:           ${GPU_ARCH}
  ROCm version:         ${ROCM_VERSION}
  ROCm path:            ${ROCM_PATH}
  Build jobs / fetch:   ${BUILD_JOBS} / ${SPACK_FETCH_JOBS}
============================================================================
EOF

if [ ! -d "${ROCM_PATH}" ]; then
    echo "ERROR: ROCM_PATH=${ROCM_PATH} does not exist." >&2
    echo "       Set ROCM_PATH or ROCM_VERSION before running this script." >&2
    exit 1
fi

mkdir -p "${BUILD_ROOT}/environments" "${BUILD_ROOT}/install" "${BUILD_ROOT}/spack_stage"

# ---------------------------------------------------------------------------
# 1. Clone Spack itself
# ---------------------------------------------------------------------------
if [ ! -d "${SPACK_GIT_DIR}" ]; then
    echo "INFO: Cloning Spack ${SPACK_BRANCH} into ${SPACK_GIT_DIR}"
    git clone https://github.com/spack/spack.git \
        --branch "${SPACK_BRANCH}" --single-branch "${SPACK_GIT_DIR}"
fi

# Source Spack
# shellcheck disable=SC1091
source "${SPACK_GIT_DIR}/share/spack/setup-env.sh"

# ---------------------------------------------------------------------------
# 2. config.yaml: redirect install tree, build stage, environments and
#    caches under BUILD_ROOT so a single directory contains everything.
# ---------------------------------------------------------------------------
SPACK_CONFIG_YAML="${SPACK_GIT_DIR}/etc/spack/config.yaml"
if [ ! -f "${SPACK_CONFIG_YAML}" ]; then
    echo "INFO: Writing Spack config to ${SPACK_CONFIG_YAML}"
    cat > "${SPACK_CONFIG_YAML}" <<EOF
config:
  install_tree:
    root: \$spack/../install
  build_stage:
    - \$spack/../spack_stage
    - \$user_cache_path/stage
  test_stage: \$user_cache_path/test
  source_cache: \$spack/var/spack/cache
  environments_root: \$spack/../environments
  misc_cache: \$user_cache_path/cache
  build_language: C
  build_jobs: ${BUILD_JOBS}
EOF
fi

# ---------------------------------------------------------------------------
# 3. repos.yaml: pin spack-packages to a tag and apply the small in-tree
#    patch that registers gfx950/Mi350 with the CP2K Spack package. The
#    patch is harmless on other targets, so we always apply it.
# ---------------------------------------------------------------------------
SPACK_REPOS_YAML="${SPACK_GIT_DIR}/etc/spack/repos.yaml"
SPACK_PACKAGES_PATH="${BUILD_ROOT}/${SPACK_PACKAGES_GIT_DIR}"
if [ ! -f "${SPACK_REPOS_YAML}" ]; then
    echo "INFO: Writing Spack repos config to ${SPACK_REPOS_YAML}"
    cat > "${SPACK_REPOS_YAML}" <<EOF
repos:
  builtin:
    git: https://github.com/spack/spack-packages.git
    tag: ${SPACK_PACKAGES_TAG}
    destination: \$spack/../${SPACK_PACKAGES_GIT_DIR}
EOF
    spack repo update builtin

    SPACK_MI350_PATCH="${SCRIPT_DIR}/patches/0001-Add-AMD-MI350-gfx950-support-to-CP2K.patch"
    if [ -f "${SPACK_MI350_PATCH}" ]; then
        # git am needs git and a configured identity; check both up front so
        # the patch does not silently fail to apply.
        if ! command -v git >/dev/null 2>&1; then
            echo "ERROR: git not found; required to apply the gfx950 patch." >&2
            exit 1
        fi
        git_user="$(git config --get user.name || true)"
        git_email="$(git config --get user.email || true)"
        if [ -z "${git_user}" ] || [ -z "${git_email}" ]; then
            echo "ERROR: git identity not configured; 'git am' will fail." >&2
            echo "       Set it before building, e.g.:" >&2
            echo "         git config --global user.name \"Your Name\"" >&2
            echo "         git config --global user.email \"you@example.com\"" >&2
            exit 1
        fi
        echo "INFO: Applying gfx950 patch from ${SPACK_MI350_PATCH}"
        pushd "${SPACK_PACKAGES_PATH}" >/dev/null
        # If we're rerunning into a partially-applied tree, skip silently.
        git am --keep-cr "${SPACK_MI350_PATCH}" >/dev/null 2>&1 || \
            git am --abort >/dev/null 2>&1 || true
        popd >/dev/null
    else
        echo "WARN: ${SPACK_MI350_PATCH} not found; skipping gfx950 patch." >&2
    fi

    if ! spack find "gcc@${GCC_VERSION}" >/dev/null 2>&1; then
        echo "INFO: Installing gcc@${GCC_VERSION} with Spack"
        spack install -p"${SPACK_FETCH_JOBS}" "gcc@${GCC_VERSION}"
    fi
fi

# ---------------------------------------------------------------------------
# 4. Spack environment definition (cp2k)
# ---------------------------------------------------------------------------
SPACK_CP2K_ENV="${BUILD_ROOT}/environments/cp2k/spack.yaml"
if [ ! -f "${SPACK_CP2K_ENV}" ]; then
    echo "INFO: Writing CP2K Spack environment to ${SPACK_CP2K_ENV}"
    mkdir -p "$(dirname "${SPACK_CP2K_ENV}")"

    cat > "${SPACK_CP2K_ENV}" <<EOF
spack:
  definitions:
  - compilers: [gcc@${GCC_VERSION}]
  - mpicompilers: [gcc@${GCC_VERSION}^openmpi@5.0.10]
  - deps:
    - boost
    - camp
    - cxxopts
    - dftd4
    - gsl
    - libint
    - libxc
    - libxsmm
    - mctc-lib
    - mstore
    - multicharge
    - openblas
    - pugixml
    - simple-dftd3
    - spglib
    - tiled-mm
    - toml-f
  - mpideps:
    - cosma
    - costa
    - dbcsr
    - fftw
    - hdf5
    - libvdwxc
    - netlib-scalapack
    - sirius
    - spfft
    - spla
    - umpire

  specs:
  - ucc%gcc@${GCC_VERSION}
  - ucx%gcc@${GCC_VERSION}
  - openmpi%gcc@${GCC_VERSION}
  - matrix:
    - [\$deps]
    - [\$%compilers]
  - matrix:
    - [\$mpideps]
    - [\$%mpicompilers]
  - cp2k%gcc@${GCC_VERSION}

  packages:
    all:
      require:
      - target=${CPU_ARCH}

    cp2k:
      version: [2026.1]
      require:
      - +libxc+libint+hdf5~dlaf~elpa+cosma+spla+sirius+vdwxc+pw_gpu+rocm smm=libxsmm amdgpu_target=${GPU_ARCH} ^libxsmm@1.17

    boost:
      version: [1.90.0]
      require:
      - +atomic+chrono+exception+system+thread

    camp:
      version: [2025.12.0]
      require:
      - +rocm amdgpu_target:=${GPU_ARCH}

    cxxopts:
      version: [3.3.1]

    dftd4:
      version: [3.7.0]
      require:
      - +openmp

    gsl:
      version: [2.8]
      require:
      - +pic+shared

    libint:
      version: [2.11.2]
      require:
      - +fma+fortran+shared tune=cp2k-lmax-5

    libxc:
      version: [7.0.0]
      require:
      - +fortran+shared

    mctc-lib:
      version: [0.3.2]

    mstore:
      version: [0.3.0]
      require:
      - +openmp

    multicharge:
      version: [0.3.1]
      require:
      - +openmp

    openblas:
      version: [0.3.30]
      require:
      - +fortran threads=openmp

    pugixml:
      version: ['1.14']
      require:
      - +pic+shared

    simple-dftd3:
      version: [1.2.1]
      require:
      - +openmp

    spglib:
      version: [2.7.0]
      require:
      - +fortran+shared

    tiled-mm:
      version: [2.3.2]
      require:
      - +rocm+shared amdgpu_target:=${GPU_ARCH}

    toml-f:
      version: [0.4.2]

    cosma:
      version: [2.7.0]
      require:
      - +apps+gpu_direct~rccl+rocm+scalapack+shared

    costa:
      version: [2.2.4]
      require:
      - +scalapack+shared

    dbcsr:
      version: [2.9.1]
      require:
      - +mpi+openmp+rocm+shared amdgpu_target:=${GPU_ARCH} smm=libxsmm ^libxsmm@1.17

    fftw:
      version: [3.3.10]
      require:
      - +mpi+openmp+shared

    hdf5:
      version: [1.14.6]
      require:
      - +cxx+fortran+hl+mpi+shared+threadsafe+tools

    libvdwxc:
      version: [0.5.0]
      require:
      - +mpi

    netlib-scalapack:
      version: [2.2.2]
      require:
      - +shared

    sirius:
      version: [7.9.0]
      require:
      - +apps+dftd3+dftd4+fortran+memory_pool+openmp+profiler+pugixml+rocm+scalapack+shared+vdwxc amdgpu_target:=${GPU_ARCH}

    spfft:
      version: [1.1.1]
      require:
      - +fortran+gpu_direct+mpi+openmp+rocm amdgpu_target:=${GPU_ARCH}

    spla:
      version: [1.6.1]
      require:
      - +fortran+rocm

    umpire:
      version: [2025.12.0]
      require:
      - +fortran+mpi+rocm amdgpu_target:=${GPU_ARCH}

    ucc:
      version: [1.7.0]
      require:
      - ~rccl+rocm amdgpu_target:=${GPU_ARCH}

    ucx:
      version: [1.20.0]
      require:
      - +verbs+mlx5_dv+dc+rc+ud+rocm+thread_multiple

    openmpi:
      version: [5.0.10]
      require:
      - +atomics+fortran+rocm+rsh+vt+wrapper-rpath amdgpu_target:=${GPU_ARCH} fabrics:=ucc,ucx

    hip:
      externals:
      - spec: hip@${ROCM_VERSION} amdgpu_target:=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    hipblas:
      externals:
      - spec: hipblas@${ROCM_VERSION} amdgpu_target:=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    hipfft:
      externals:
      - spec: hipfft@${ROCM_VERSION} amdgpu_target:=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    hsa-rocr-dev:
      externals:
      - spec: hsa-rocr-dev@${ROCM_VERSION} amdgpu_target:=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    llvm-amdgpu:
      externals:
      - spec: llvm-amdgpu@${ROCM_VERSION} amdgpu_target=${GPU_ARCH} languages:='c,c++,fortran'
        prefix: ${ROCM_PATH}
        extra_attributes:
          compilers:
            c: ${ROCM_PATH}/bin/amdclang
            cxx: ${ROCM_PATH}/bin/amdclang++
            fortran: ${ROCM_PATH}/bin/amdflang
      buildable: false

    rocblas:
      externals:
      - spec: rocblas@${ROCM_VERSION} amdgpu_target=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    rocfft:
      externals:
      - spec: rocfft@${ROCM_VERSION} amdgpu_target=${GPU_ARCH} amdgpu_target_sram_ecc=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    rocm-opencl:
      externals:
      - spec: rocm-opencl@${ROCM_VERSION} amdgpu_target=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    rocm-smi-lib:
      externals:
      - spec: rocm-smi-lib@${ROCM_VERSION} amdgpu_target=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    rocsolver:
      externals:
      - spec: rocsolver@${ROCM_VERSION} amdgpu_target=${GPU_ARCH}
        prefix: ${ROCM_PATH}
      buildable: false

    rdma-core:
      externals:
      - spec: rdma-core@52.0
        prefix: /
      buildable: false

  view: false
  concretizer:
    targets:
      granularity: microarchitectures
    unify: when_possible
    duplicates:
      strategy: minimal
EOF

    spack -e cp2k compiler find "$(spack location -i "gcc@${GCC_VERSION}")"
fi

# ---------------------------------------------------------------------------
# 5. Concretize and install
# ---------------------------------------------------------------------------
echo "INFO: Concretizing CP2K environment"
spack -e cp2k concretize --fresh -f

echo "INFO: Building CP2K (this can take 1-3 hours)"
spack -e cp2k install -j"${BUILD_JOBS}" -p"${SPACK_FETCH_JOBS}"

# Convenience symlink (./cp2k -> CP2K install prefix)
CP2K_PREFIX=$(spack -e cp2k location -i cp2k 2>/dev/null || true)
if [ -n "${CP2K_PREFIX}" ] && [ -d "${CP2K_PREFIX}" ]; then
    ln -sfn "${CP2K_PREFIX}" "${BUILD_ROOT}/cp2k"
    echo "INFO: Installed CP2K at ${CP2K_PREFIX}"
    echo "INFO: Symlink created: ${BUILD_ROOT}/cp2k -> ${CP2K_PREFIX}"
fi

cat <<EOF

============================================================================
  CP2K BUILD COMPLETE
============================================================================
  Spack root:        ${SPACK_GIT_DIR}
  Install tree:      ${BUILD_ROOT}/install
  Environment:       ${BUILD_ROOT}/environments/cp2k
  CP2K prefix:       ${CP2K_PREFIX:-<not detected>}

To use CP2K:
  source ${SPACK_GIT_DIR}/share/spack/setup-env.sh
  spack env activate cp2k
  spack load cp2k
  cp2k.psmp --version
============================================================================
EOF
