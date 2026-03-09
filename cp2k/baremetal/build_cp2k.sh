#!/bin/bash

# ============================================================================
# CP2K Baremetal Build Script using Spack
# ============================================================================
# This script builds CP2K with ROCm support on bare metal using Spack
# It mirrors the Docker build approach but for direct system installation
#
# Usage:
#   ./build_cp2k.sh [OPTIONS]
#
# Options:
#   --install-prefix PATH    Installation directory (default: $PWD/cp2k-baremetal)
#   --spack-root PATH        Spack installation directory (default: ~/spack)
#   --rocm-path PATH         ROCm installation path (default: $ROCM_PATH or /opt/rocm)
#   --gpu-target TARGET      AMD GPU target (default: gfx942)
#   --jobs N                 Number of parallel build jobs (default: 16)
#   --help                   Show this help message
# ============================================================================

set -e  # Exit on error

# ============================================================================
# Default Configuration
# ============================================================================

# Set WORKDIR to current working directory
WORKDIR="${PWD}"
INSTALL_PREFIX="$WORKDIR/cp2k-baremetal"
SPACK_ROOT="$HOME/spack"
ROCM_PATH="${ROCM_PATH:-/opt/rocm}"
AMDGPU_TARGET="gfx942"
BUILD_JOBS=16

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CP2K_ENV_DIR="$SCRIPT_DIR/../docker/cp2k_environment"

# ============================================================================
# Parse Command Line Arguments
# ============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --install-prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --spack-root)
            SPACK_ROOT="$2"
            shift 2
            ;;
        --rocm-path)
            ROCM_PATH="$2"
            shift 2
            ;;
        --gpu-target)
            AMDGPU_TARGET="$2"
            shift 2
            ;;
        --jobs)
            BUILD_JOBS="$2"
            shift 2
            ;;
        --help)
            grep "^#" "$0" | grep -v "^#!/" | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Color Output Functions
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
section() { echo -e "\n${BLUE}========== $1 ==========${NC}\n"; }

# ============================================================================
# Banner
# ============================================================================

echo ""
echo "============================================================================"
echo "  CP2K Baremetal Build Script"
echo "============================================================================"
echo "  Working Directory: $WORKDIR"
echo "  Install Prefix:    $INSTALL_PREFIX"
echo "  Spack Root:        $SPACK_ROOT"
echo "  ROCm Path:         $ROCM_PATH"
echo "  GPU Target:        $AMDGPU_TARGET"
echo "  Build Jobs:        $BUILD_JOBS"
echo "  Environment:       $CP2K_ENV_DIR"
echo "============================================================================"
echo ""

# ============================================================================
# Prerequisite Checks
# ============================================================================

section "Checking Prerequisites"

# Check for CP2K environment directory
if [ ! -d "$CP2K_ENV_DIR" ]; then
    error "CP2K environment directory not found at: $CP2K_ENV_DIR"
fi

if [ ! -f "$CP2K_ENV_DIR/spack.yaml" ]; then
    error "spack.yaml not found in: $CP2K_ENV_DIR"
fi

info "CP2K environment found at: $CP2K_ENV_DIR"

# Check for ROCm
if [ ! -d "$ROCM_PATH" ]; then
    error "ROCm not found at $ROCM_PATH. Please set --rocm-path or install ROCm."
fi

info "ROCm found at: $ROCM_PATH"

# Check for required tools
MISSING_TOOLS=()
for tool in git gcc gfortran cmake make; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS+=($tool)
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    error "Missing required tools: ${MISSING_TOOLS[*]}"
fi

info "All required tools found: git, gcc, gfortran, cmake, make"

# ============================================================================
# Spack Installation
# ============================================================================

section "Setting Up Spack"

if [ ! -d "$SPACK_ROOT" ]; then
    info "Spack not found. Cloning Spack to $SPACK_ROOT..."
    git clone https://github.com/spack/spack.git "$SPACK_ROOT"
    info "Spack cloned successfully"
else
    info "Spack found at: $SPACK_ROOT"
fi

# Source Spack
if [ ! -f "$SPACK_ROOT/share/spack/setup-env.sh" ]; then
    error "Spack setup script not found at: $SPACK_ROOT/share/spack/setup-env.sh"
fi

source "$SPACK_ROOT/share/spack/setup-env.sh"

info "Spack version: $(spack --version)"

# ============================================================================
# System Package Detection
# ============================================================================

section "Detecting System Packages and Compilers"

info "Finding compilers..."
spack compiler find

info "Finding external packages..."
spack external find --all

echo ""
info "Detected compilers:"
spack compiler list

# ============================================================================
# Create Spack Environment
# ============================================================================

section "Creating Spack Environment"

ENV_NAME="cp2k-baremetal"
BAREMETAL_ENV_DIR="$HOME/.spack/environments/$ENV_NAME"
SPACK_ENV_DIR="$SPACK_ROOT/var/spack/environments/$ENV_NAME"

# Check if environment already exists and remove it
if spack env list | grep -qw "$ENV_NAME"; then
    warn "Spack environment '$ENV_NAME' already exists"
    info "Removing existing environment to recreate with updated configuration..."
    spack env rm -y $ENV_NAME 2>/dev/null || true
    rm -rf "$BAREMETAL_ENV_DIR" 2>/dev/null || true
    rm -rf "$SPACK_ENV_DIR" 2>/dev/null || true
    info "Environment removed"
fi

# Wait a moment to ensure cleanup is complete
sleep 1

# Create environment
info "Creating Spack environment: $ENV_NAME"
spack env create $ENV_NAME "$CP2K_ENV_DIR/spack.yaml" || {
    error "Failed to create Spack environment. Trying to remove and recreate..."
    rm -rf "$SPACK_ENV_DIR" 2>/dev/null || true
    rm -rf "$BAREMETAL_ENV_DIR" 2>/dev/null || true
    sleep 1
    spack env create $ENV_NAME "$CP2K_ENV_DIR/spack.yaml"
}

# Create/overwrite custom config for baremetal install path BEFORE activating
info "Configuring install tree: $INSTALL_PREFIX/cp2k-dist"
mkdir -p "$SPACK_ENV_DIR"

# Write config.yaml directly to the environment directory
cat > "$SPACK_ENV_DIR/config.yaml" <<EOF
config:
  install_tree:
    root: $INSTALL_PREFIX/cp2k-dist
  build_stage:
    - \$tempdir/\$user/spack-stage
    - ~/.spack/stage
  source_cache: ~/.spack/cache
  misc_cache: ~/.spack/misc_cache
  concretizer:
    reuse: dependencies
EOF

info "Environment configuration written to $SPACK_ENV_DIR/config.yaml"

# Activate the environment
info "Activating environment: $ENV_NAME"
spack env activate $ENV_NAME

# Verify the config was applied
INSTALL_ROOT=$(spack config get config:install_tree:root 2>/dev/null | grep -v "^--" | head -1 | sed 's/^[[:space:]]*root:[[:space:]]*//' || echo "")
if [ -n "$INSTALL_ROOT" ]; then
    info "Verified install tree root: $INSTALL_ROOT"
else
    warn "Could not verify install tree root, but config.yaml was written"
fi

# ============================================================================
# Configure ROCm and Build Environment
# ============================================================================

section "Configuring Build Environment"

info "Setting up ROCm environment variables..."

export ROCM_PATH=$ROCM_PATH
export PATH=$ROCM_PATH/bin:$PATH
export LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$LIBRARY_PATH
export C_INCLUDE_PATH=$ROCM_PATH/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$CPLUS_INCLUDE_PATH
export CMAKE_PREFIX_PATH=$ROCM_PATH/lib/cmake:$CMAKE_PREFIX_PATH

# Additional ROCm library paths
export LD_LIBRARY_PATH=$ROCM_PATH/lib/hipblas:$ROCM_PATH/lib/hipfft:$ROCM_PATH/lib/rocfft:$ROCM_PATH/lib/rocblas:$LD_LIBRARY_PATH
export LIBRARY_PATH=$ROCM_PATH/lib/rocfft:$ROCM_PATH/lib/hipblas:$ROCM_PATH/lib/rocblas:$LIBRARY_PATH
export C_INCLUDE_PATH=$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/rocblas:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/rocblas:$CPLUS_INCLUDE_PATH

info "ROCm environment configured"
info "GPU Target: $AMDGPU_TARGET"

# Note: UCX, UCC, and OpenMPI will be detected as external packages by Spack
# via 'spack external find --all' command below

# ============================================================================
# Concretize Dependencies
# ============================================================================

section "Concretizing Dependencies"

info "Analyzing and resolving package dependencies..."
info "This may take several minutes..."

spack concretize -f 2>&1 | tee $INSTALL_PREFIX/concretize.log || {
    error "Concretization failed. Check $INSTALL_PREFIX/concretize.log for details"
}

info "Dependency tree:"
spack find

# ============================================================================
# Build and Install
# ============================================================================

section "Building CP2K and Dependencies"

warn "This will take a significant amount of time (2-4 hours depending on system)"
warn "Build logs will be saved to: $INSTALL_PREFIX/build.log"

info "Starting build with $BUILD_JOBS parallel jobs..."

# Create install prefix
mkdir -p "$INSTALL_PREFIX"

START_TIME=$(date +%s)

if spack install -j${BUILD_JOBS} --verbose 2>&1 | tee -a $INSTALL_PREFIX/build.log; then
    END_TIME=$(date +%s)
else
    error "Build failed. Check $INSTALL_PREFIX/build.log for details"
    exit 1
fi
BUILD_DURATION=$((END_TIME - START_TIME))
BUILD_HOURS=$((BUILD_DURATION / 3600))
BUILD_MINUTES=$(((BUILD_DURATION % 3600) / 60))

info "Build completed in ${BUILD_HOURS}h ${BUILD_MINUTES}m"

# ============================================================================
# Create Installation Links and Setup Scripts
# ============================================================================

section "Finalizing Installation"

# Find CP2K installation path
info "Locating CP2K installation..."
CP2K_INSTALL_PATH=$(spack find -p cp2k@2026.1 | tail -n 1 | awk '{print $2}')

if [ -z "$CP2K_INSTALL_PATH" ] || [ ! -d "$CP2K_INSTALL_PATH" ]; then
    error "Failed to find CP2K installation path"
fi

info "CP2K installed at: $CP2K_INSTALL_PATH"

# Create symlink for easy access
info "Creating convenience symlink..."
ln -sf "$CP2K_INSTALL_PATH" "$INSTALL_PREFIX/cp2k"
info "Symlink created: $INSTALL_PREFIX/cp2k -> $CP2K_INSTALL_PATH"

# Create environment setup script
info "Creating environment setup script..."

cat > "$INSTALL_PREFIX/setup_cp2k.sh" <<'EOFSETUP'
#!/bin/bash
# ============================================================================
# CP2K Environment Setup Script
# ============================================================================
# Source this file to use CP2K: source <install_prefix>/setup_cp2k.sh
# ============================================================================

SPACK_ROOT="${SPACK_ROOT:-$HOME/spack}"
INSTALL_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source Spack
if [ -f "$SPACK_ROOT/share/spack/setup-env.sh" ]; then
    source "$SPACK_ROOT/share/spack/setup-env.sh"
else
    echo "Error: Spack not found at $SPACK_ROOT"
    return 1
fi

# Activate CP2K environment
spack env activate cp2k-baremetal

# Add CP2K to PATH
export PATH=$INSTALL_PREFIX/cp2k/bin:$PATH

# Set MPI/UCX environment for optimal performance
export OMPI_MCA_pml=ucx
export OMPI_MCA_pml_ucx_tls=any
export OMPI_MCA_osc=ucx
export OMPI_MCA_btl=^vader,tcp,uct
export OMPI_MCA_pml_ucx_devices=any
export UCX_TLS=self,sm,tcp,rocm

echo "CP2K environment activated"
echo "CP2K path: $INSTALL_PREFIX/cp2k"

# Verify CP2K is available
if command -v cp2k.psmp &> /dev/null; then
    echo "CP2K executable: $(which cp2k.psmp)"
else
    echo "Warning: cp2k.psmp not found in PATH"
fi
EOFSETUP

chmod +x "$INSTALL_PREFIX/setup_cp2k.sh"

# Create a convenience module file for environment modules (if system uses modules)
info "Creating environment module file..."

MODULEFILE_DIR="$INSTALL_PREFIX/modulefiles"
mkdir -p "$MODULEFILE_DIR"

cat > "$MODULEFILE_DIR/cp2k-baremetal" <<EOFMODULE
#%Module1.0
##
## CP2K Baremetal Module
##

proc ModulesHelp { } {
    puts stderr "CP2K with ROCm support built using Spack"
    puts stderr ""
    puts stderr "This module adds CP2K to your environment"
}

module-whatis "CP2K quantum chemistry software with ROCm GPU support"

set SPACK_ROOT $SPACK_ROOT
set INSTALL_PREFIX $INSTALL_PREFIX

if { [file exists \$SPACK_ROOT/share/spack/setup-env.sh] } {
    set-alias spack-setup "source \$SPACK_ROOT/share/spack/setup-env.sh && spack env activate cp2k-baremetal"
}

prepend-path PATH \$INSTALL_PREFIX/cp2k/bin

setenv OMPI_MCA_pml ucx
setenv OMPI_MCA_pml_ucx_tls any
setenv OMPI_MCA_osc ucx
setenv OMPI_MCA_btl ^vader,tcp,uct
setenv OMPI_MCA_pml_ucx_devices any
setenv UCX_TLS self,sm,tcp,rocm
EOFMODULE

info "Module file created: $MODULEFILE_DIR/cp2k-baremetal"

# ============================================================================
# Verify Installation
# ============================================================================

section "Verifying Installation"

if [ -x "$CP2K_INSTALL_PATH/bin/cp2k.psmp" ]; then
    info "✓ CP2K executable found: $CP2K_INSTALL_PATH/bin/cp2k.psmp"
    
    # Try to run version command
    if "$CP2K_INSTALL_PATH/bin/cp2k.psmp" --version > /dev/null 2>&1; then
        info "✓ CP2K version check passed"
        "$CP2K_INSTALL_PATH/bin/cp2k.psmp" --version | head -n 5
    else
        warn "CP2K executable found but version check failed"
    fi
else
    error "CP2K executable not found at: $CP2K_INSTALL_PATH/bin/cp2k.psmp"
fi

# Check for benchmark directory
BENCHMARK_DIR="$SCRIPT_DIR/../cp2k/benchmarks"
if [ -d "$BENCHMARK_DIR" ]; then
    info "✓ Benchmark directory found: $BENCHMARK_DIR"
else
    warn "Benchmark directory not found at: $BENCHMARK_DIR"
fi

# ============================================================================
# Installation Summary
# ============================================================================

section "Installation Complete!"

cat <<EOF

============================================================================
  CP2K BUILD COMPLETED SUCCESSFULLY!
============================================================================

Installation Details:
  Install Prefix:     $INSTALL_PREFIX
  CP2K Path:          $CP2K_INSTALL_PATH
  Spack Environment:  cp2k-baremetal
  GPU Target:         $AMDGPU_TARGET
  Build Time:         ${BUILD_HOURS}h ${BUILD_MINUTES}m

Files Created:
  Setup Script:       $INSTALL_PREFIX/setup_cp2k.sh
  Module File:        $MODULEFILE_DIR/cp2k-baremetal
  Build Log:          $INSTALL_PREFIX/build.log
  Concretize Log:     $INSTALL_PREFIX/concretize.log

============================================================================
USAGE INSTRUCTIONS
============================================================================

To use CP2K, choose one of the following methods:

1. Source the setup script (recommended):
   source $INSTALL_PREFIX/setup_cp2k.sh

2. Activate Spack environment directly:
   source $SPACK_ROOT/share/spack/setup-env.sh
   spack env activate cp2k-baremetal

3. Add to PATH directly:
   export PATH=$CP2K_INSTALL_PATH/bin:\$PATH

4. Use environment module (if modules are available):
   module use $MODULEFILE_DIR
   module load cp2k-baremetal

============================================================================
RUNNING BENCHMARKS
============================================================================

Example SLURM commands:

# Single node, 8 GPUs, 4 ranks (2 GPUs per rank):
srun -N 1 --gpus-per-node=8 --ntasks=4 --cpus-per-task=16 \\
  cp2k.psmp -i input.inp -o output.out

# Single node, 8 GPUs, 8 ranks (1 GPU per rank):
srun -N 1 --gpus-per-node=8 --ntasks=8 --cpus-per-task=8 \\
  cp2k.psmp -i input.inp -o output.out

# Two nodes, 16 GPUs, 16 ranks:
srun -N 2 --gpus-per-node=8 --ntasks-per-node=8 --cpus-per-task=8 \\
  cp2k.psmp -i input.inp -o output.out

Example benchmark:
cd $BENCHMARK_DIR/QS_DM_LS
source $INSTALL_PREFIX/setup_cp2k.sh
srun -N 1 --gpus-per-node=8 --ntasks=4 --cpus-per-task=16 \\
  cp2k.psmp -i H2O-dft-ls.NREP2.inp -o H2O-DFT-4ranks.out

============================================================================

For questions or issues, refer to:
  - Build logs: $INSTALL_PREFIX/build.log
  - CP2K documentation: https://manual.cp2k.org/

============================================================================
EOF

info "Installation summary saved to: $INSTALL_PREFIX/INSTALL_SUMMARY.txt"

cat <<EOF > "$INSTALL_PREFIX/INSTALL_SUMMARY.txt"
CP2K Baremetal Installation Summary
====================================

Installation Date: $(date)
Host: $(hostname)
User: $(whoami)

Configuration:
  Install Prefix: $INSTALL_PREFIX
  CP2K Path: $CP2K_INSTALL_PATH
  Spack Root: $SPACK_ROOT
  ROCm Path: $ROCM_PATH
  GPU Target: $AMDGPU_TARGET
  Build Jobs: $BUILD_JOBS
  Build Time: ${BUILD_HOURS}h ${BUILD_MINUTES}m

Setup Script: $INSTALL_PREFIX/setup_cp2k.sh
Module File: $MODULEFILE_DIR/cp2k-baremetal
Build Log: $INSTALL_PREFIX/build.log
EOF

info "Done!"

