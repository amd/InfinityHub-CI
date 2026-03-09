# CP2K Bare Metal Build Instructions

This document provides instructions on how to build CP2K on bare metal using Spack for dependency management. This approach provides a reproducible installation of CP2K with all its scientific computing dependencies built with ROCm support.

## Build System Requirements

### Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver |
| ---- | ---- | ----------------- | ------------ |
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> AMD Instinct MI300 GPU(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <br> Ubuntu 24.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v7.x compatibility |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

### Required Software

| Application | Minimum | Recommended |
|---|---|---|
| Git | Latest | Latest |
| GCC | 11.3.0 | Latest |
| GFortran | 11.3.0 | Latest |
| CMake | 3.22 | Latest |
| Make | Latest | Latest |
| ROCm | 7.0.0 | Latest |
| OpenMPI | 5.0.3 | 5.0.8+ |
| Python | 3.6+ | 3.8+ |

### Recommended Resources

- **Disk Space**: 50+ GB for build artifacts and Spack installations
- **Memory**: 32+ GB RAM
- **Build Time**: 2-4 hours (depending on system and parallel jobs)

## Overview

This bare metal build uses **Spack** to build CP2K and its scientific computing dependencies. This is the **recommended build method from the CP2K developer community**, providing a robust and maintainable approach. System-installed packages (GCC, OpenMPI, ROCm) are detected as external packages and are not built by Spack.

The build process:
1. Installs and configures Spack package manager
2. Uses a Spack environment (`../docker/cp2k_environment/spack.yaml`) to build CP2K and its Spack-managed dependencies
3. Detects system-installed packages (GCC, ROCm, OpenMPI, etc.) as external packages
4. Builds CP2K dependencies via Spack (SIRIUS, COSMA, DBCSR, libxc, libint, etc.)
5. Compiles CP2K with ROCm GPU acceleration
6. Creates setup scripts for easy environment activation

> **Note**: GCC, OpenMPI, UCX, and UCC must be system-installed and are not built by this script. They are detected as external packages by Spack.

## Quick Start

### 1. Navigate to Baremetal Directory

```bash
cd /path/to/cp2k/baremetal
```

### 2. Run the Build Script

```bash
./build_cp2k.sh
```

This will:
- Check prerequisites (ROCm, GCC, compilers, OpenMPI, etc.)
- Install/configure Spack if needed
- Create a Spack environment using the shared `cp2k_environment` configuration
- Detect system-installed packages (GCC, OpenMPI, ROCm, etc.) as external packages
- Build CP2K dependencies (SIRIUS, COSMA, DBCSR, etc.) and CP2K via Spack
- Create setup scripts for environment activation
- Save build logs to `build.log`

### 3. Activate CP2K Environment

After successful build:

```bash
source cp2k-baremetal/setup_cp2k.sh
cp2k.psmp --version
```

## Build Script Options

The `build_cp2k.sh` script supports the following options:

| Option | Description | Default |
|--------|-------------|---------|
| `--install-prefix PATH` | Installation directory | `$PWD/cp2k-baremetal` |
| `--spack-root PATH` | Spack installation directory | `~/spack` |
| `--rocm-path PATH` | ROCm installation path | `$ROCM_PATH` or `/opt/rocm` |
| `--gpu-target TARGET` | AMD GPU architecture | `gfx942` (MI300) |
| `--jobs N` | Parallel build jobs | `16` |
| `--help` | Show help message | - |

### Custom Configuration Examples

**Custom Installation Path:**
```bash
./build_cp2k.sh --install-prefix /opt/cp2k-mi300
```

**Specify Spack Location:**
```bash
./build_cp2k.sh --spack-root /path/to/spack
```

**Different GPU Target:**
```bash
# For MI300 series (gfx942)
./build_cp2k.sh --gpu-target gfx942

# For MI200 series (gfx90a)
./build_cp2k.sh --gpu-target gfx90a

# For MI100 series (gfx908)
./build_cp2k.sh --gpu-target gfx908
```

**Control Build Parallelism:**
```bash
./build_cp2k.sh --jobs 32
```

**Complete Example:**
```bash
./build_cp2k.sh \
  --install-prefix /opt/cp2k-mi300 \
  --spack-root $HOME/spack \
  --rocm-path /opt/rocm-6.3.0 \
  --gpu-target gfx90a \
  --jobs 32
```

> **DISCLAIMER**: This bare metal build has only been validated using the default values. Using different GPU targets, ROCm versions, or build options may result in build failures or poor performance.

## Spack Environment Configuration

The CP2K build uses the shared Spack environment located in `../docker/cp2k_environment/`:

- **`spack.yaml`**: Defines all package specifications, variants, and build options
- **`repos/`**: Custom Spack package repositories (contains CP2K, DBCSR, libvdwxc packages)
- **`config.yaml`**: Spack configuration settings

### Key CP2K Variants

The CP2K package is built with the following variants (see `spack.yaml`):
- `+rocm`: ROCm GPU acceleration
- `+cosma`: COSMA library for matrix operations
- `+sirius`: SIRIUS library for electronic structure
- `+spglib`: Space group library
- `+hdf5`: HDF5 I/O support
- `+mpi`: MPI parallelization
- `+openmp`: OpenMP threading
- `smm=libxsmm`: Small matrix multiplication via libxsmm

### GPU Architecture Configuration

The GPU architecture target is configured via the `--gpu-target` option and is set in the Spack environment via the `amdgpu_target` variant. Common targets:
- `gfx908`: MI100 series
- `gfx90a`: MI200 series
- `gfx942`: MI300 series

### Modifying the Build

To change CP2K variants or dependencies:

1. Edit `../docker/cp2k_environment/spack.yaml`
2. Modify the `cp2k@2026.1` spec line with desired variants
3. Rebuild: `./build_cp2k.sh`

Example: To disable a feature, change `+feature` to `~feature` in the spec.

## Build Process Details

The build script follows these steps:

1. **Prerequisite Checks**: Verifies ROCm installation, GCC, compilers, OpenMPI, and required tools
2. **Spack Setup**: Clones Spack if needed and sources the environment
3. **System Detection**: Finds system compilers (GCC) and external packages (ROCm, OpenMPI, UCX, UCC, etc.)
4. **Environment Creation**: Creates a Spack environment using the shared `cp2k_environment`
5. **Dependency Resolution**: Concretizes the dependency graph (using external GCC, OpenMPI, UCX, UCC)
6. **Build**: Installs CP2K dependencies (SIRIUS, COSMA, DBCSR, etc.) and CP2K with parallel jobs
7. **Setup Scripts**: Creates environment setup scripts and module files

### Build Time

Expected build times:
- Spack setup and dependency resolution: ~5-10 minutes
- Dependency builds (SIRIUS, COSMA, DBCSR, libxc, libint, etc.): ~30-60 minutes
- CP2K compilation: ~10-20 minutes
- **Total**: ~45-90 minutes (depending on system and parallel jobs)

> **Note**: GCC, OpenMPI, UCX, and UCC are expected to be system-installed and are detected as external packages by Spack. They are not built by this script.

## Running CP2K

### Environment Setup

Choose one of these methods:

#### Method 1: Setup Script (Recommended)
```bash
source cp2k-baremetal/setup_cp2k.sh
```

#### Method 2: Spack Environment
```bash
source ~/spack/share/spack/setup-env.sh
spack env activate cp2k-baremetal
```

#### Method 3: Direct PATH
```bash
export PATH=cp2k-baremetal/cp2k/bin:$PATH
```

### CP2K Executables

The build provides CP2K executables via the Spack environment:

- **`cp2k.psmp`**: Parallel SMP (Shared Memory Parallel) version
  - Built with MPI and OpenMP support
  - Includes ROCm GPU acceleration
  - Located at `cp2k-baremetal/cp2k/bin/cp2k.psmp` (also in PATH)

The executable is accessible via:
- Direct path: `cp2k-baremetal/cp2k/bin/cp2k.psmp`
- PATH: `cp2k.psmp` (after sourcing setup script)
- Spack environment: `spack load cp2k`

### Running Benchmarks

Example benchmark scripts are provided in `scripts/`:

- **`run_dft_nrep2.sh`**: DFT benchmark with 16 MPI ranks
- **`run_rpa32.sh`**: RPA benchmark with two stages (init + solver)
- **`set_cpu_affinity.sh`** and **`set_gpu_affinity.sh`**: Affinity scripts that can be tuned for the system the benchmarks are run on

> **DISCLAIMER**: The affinity scripts (`set_cpu_affinity.sh` and `set_gpu_affinity.sh`) must be tuned according to your specific system configuration to achieve maximum performance. The default settings may not be optimal for all hardware configurations.

To run benchmarks:

```bash
cd /path/to/cp2k/baremetal
source cp2k-baremetal/setup_cp2k.sh
./scripts/run_dft_nrep2.sh
```

These scripts handle:
- CP2K repository cloning
- CPU/GPU affinity setup
- Output file management

### SLURM Job Examples

#### Single Node, 8 GPUs, 4 MPI Ranks
```bash
#!/bin/bash
#SBATCH --job-name=cp2k_test
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=16
#SBATCH --gpus-per-node=8
#SBATCH --time=01:00:00

source cp2k-baremetal/setup_cp2k.sh

srun --gpus-per-node=8 --ntasks=4 --cpus-per-task=16 \
  cp2k.psmp -i input.inp -o output.out
```

#### Single Node, 8 GPUs, 8 MPI Ranks
```bash
srun -N 1 --gpus-per-node=8 --ntasks=8 --cpus-per-task=8 \
  cp2k.psmp -i input.inp -o output.out
```

#### Multi-Node, 16 GPUs, 16 MPI Ranks
```bash
srun -N 2 --gpus-per-node=8 --ntasks-per-node=8 --cpus-per-task=8 \
  cp2k.psmp -i input.inp -o output.out
```

## Runtime Options

### GPU-to-GPU Communication (g2g)

To enable GPU-to-GPU communication in DBCSR, set the environment variable:

```bash
export DBCSR_USE_ACC_G2G=1
```

This can improve performance for multi-GPU runs. Example:

```bash
export DBCSR_USE_ACC_G2G=1
mpirun -np 16 -x DBCSR_USE_ACC_G2G=1 cp2k.psmp -i input.inp
```

> **Note**: For g2g to work properly, the MPI implementation must be built with ROCm support. This includes UCX and OpenMPI being compiled with ROCm/GPU support enabled. Verify your MPI installation supports GPU communication before using this option.

### MPI/UCX Configuration

The setup script automatically configures OpenMPI to use UCX (if available):
```bash
export OMPI_MCA_pml=ucx
export OMPI_MCA_pml_ucx_tls=any
export OMPI_MCA_osc=ucx
export OMPI_MCA_btl=^vader,tcp,uct
export UCX_TLS=self,sm,tcp,rocm
```

> **Note**: GCC, OpenMPI, and UCX should be system-installed. The build script detects them as external packages and does not build them.

## Troubleshooting

### Build Failures

If the build fails during Spack installation:

1. Check `build.log` for detailed error messages
2. Verify network connectivity (Spack downloads packages)
3. Ensure sufficient disk space (~50GB+ required)
4. Verify ROCm installation: `rocminfo`
5. Check compiler availability: `gcc --version`, `gfortran --version`
6. Verify OpenMPI is installed: `mpirun --version` or `which mpirun`

### Missing Executables

If CP2K executable is not found:

```bash
# Verify installation
ls -l cp2k-baremetal/cp2k/bin/

# Check environment
source cp2k-baremetal/setup_cp2k.sh
which cp2k.psmp
```

### GPU Issues

If GPU is not detected:

- Verify ROCm installation: `rocm-smi`
- Check GPU visibility: `echo $ROCR_VISIBLE_DEVICES`
- Verify GPU architecture matches `--gpu-target` used during build
- Check SLURM GPU allocation: `srun --gpus-per-node=8 rocm-smi`

### Concretization Issues

If Spack fails to resolve dependencies:

```bash
# View concretization log
cat cp2k-baremetal/concretize.log

# Try with more verbose output
source ~/spack/share/spack/setup-env.sh
spack env activate cp2k-baremetal
spack concretize -f --fresh
```

### MPI Errors

If MPI-related errors occur:

```bash
# Verify OpenMPI is installed and accessible
mpirun --version
which mpirun

# Test MPI
mpirun -np 4 hostname

# Check UCX (if installed)
ucx_info -v
```

> **Note**: GCC and OpenMPI must be system-installed before running the build script. UCX and UCC are optional but recommended for optimal performance.

## Updating the Build

### Rebuild with New Options

```bash
# Remove existing environment
source ~/spack/share/spack/setup-env.sh
spack env rm -y cp2k-baremetal

# Run build script again
./build_cp2k.sh [new options]
```

### Update Spack Environment

To modify the package specifications:

```bash
# Edit the shared environment
vim ../docker/cp2k_environment/spack.yaml

# Rebuild
./build_cp2k.sh
```

## Files Created by Build

```
cp2k-baremetal/
├── cp2k/                    # Symlink to CP2K installation
├── dist/                    # Spack install tree
├── setup_cp2k.sh           # Environment setup script
├── modulefiles/            # Environment module files
│   └── cp2k-baremetal
├── build.log               # Complete build log
├── concretize.log          # Dependency resolution log
└── INSTALL_SUMMARY.txt     # Installation summary
```

> **Note**: The default installation directory is `$PWD/cp2k-baremetal` (relative to where you run the build script). If you run the script from `/path/to/cp2k/baremetal`, the installation will be at `/path/to/cp2k/baremetal/cp2k-baremetal`. You can specify a custom path using `--install-prefix`.

## Licensing Information

Your use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:

| Package | License | URL |
|---|---|---|
| Ubuntu | Creative Commons CC-BY-SA Version 3.0 UK License | [Ubuntu Legal](https://ubuntu.com/legal) |
| CMAKE | OSI-approved BSD-3 clause | [CMake License](https://cmake.org/licensing/) |
| OpenMPI | BSD 3-Clause | [OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html) |
| OpenUCX | BSD 3-Clause | [OpenUCX License](https://openucx.org/license/) |
| ROCm | Custom/MIT/Apache V2.0/UIUC OSL | [ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html) |
| CP2K | GNU GPL Version 2 | [CP2k](https://www.cp2k.org/)<br />[CP2K License](https://github.com/cp2k/cp2k/blob/master/LICENSE) |
| Spack | Apache-2.0 OR MIT | [Spack License](https://github.com/spack/spack/blob/develop/LICENSE-APACHE) |
| OpenBlas | BSD 3-Clause | [OpenBlas](https://www.openblas.net/)<br /> [OpenBlas License](https://github.com/xianyi/OpenBLAS/blob/develop/LICENSE) |
| COSMA | BSD 3-Clause | [COSMA License](https://github.com/eth-cscs/COSMA/blob/master/LICENSE) |
| Libxsmm | BSD 3-Clause | [Libxsmm License](https://libxsmm.readthedocs.io/en/latest/LICENSE/) |
| Libxc | MPL v2.0 | [Libxc License](https://github.com/ElectronicStructureLibrary/libxc) |
| SpLA | BSD 3-Clause | [SpLA License](https://github.com/eth-cscs/spla/blob/master/LICENSE) |
| DBCSR | GPL-2.0 | [DBCSR License](https://github.com/cp2k/dbcsr) |
| SIRIUS | BSD 3-Clause | [SIRIUS License](https://github.com/electronic-structure/SIRIUS) |

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD "AS IS" WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

## Disclaimer

The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD's products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution

© 2022-26 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
