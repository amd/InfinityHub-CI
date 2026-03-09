# CP2K Container Build Instructions

This document provides instructions on how to build CP2K into a Docker container using Spack for dependency management. The container is portable between environments and includes all CP2K dependencies built with ROCm support.

## Build System Requirements

- Git
- Docker (or Podman)
- BuildKit (recommended for better caching)

## Overview

This Docker recipe uses **Spack** to build CP2K and all its dependencies. This is the **recommended build method from the CP2K developer community**, providing a robust and maintainable approach to building CP2K with all its scientific computing dependencies.

The build process:
1. Sets up the base ROCm development environment
2. Builds UCX, UCC, and OpenMPI with ROCm support
3. Installs Spack package manager
4. Uses a Spack environment (`cp2k_environment/spack.yaml`) to build CP2K and all dependencies
5. Creates a symlink at `/opt/cp2k` for easy access to CP2K executables

## Inputs

### Build Arguments

Possible `build-arg` parameters for the Docker build command:

- **IMAGE** (default: `rocm/dev-ubuntu-24.04:7.0-complete`)
  - Base container image with ROCm development tools
  - Must include ROCm 7.0+ support

- **UCX_BRANCH** (default: `v1.19.0`)
  - UCX (Unified Communication X) version for MPI communication

- **UCC_BRANCH** (default: `v1.5.1`)
  - UCC (Unified Collective Communication) version

- **OMPI_BRANCH** (default: `v5.0.8`)
  - OpenMPI version

- **AMDGPU_TARGETS** (default: `gfx908,gfx90a,gfx942`)
  - GPU architectures to target (comma-separated)
  - Common targets: `gfx908` (MI100), `gfx90a` (MI200), `gfx942` (MI300)

- **CP2K_BRANCH** (default: `v2026.1`)
  - CP2K version to build (specified in `spack.yaml`)

> **NOTE**
> The GPU architecture targets are configured in the Spack environment file (`cp2k_environment/spack.yaml`) via the `amdgpu_target` variant. The default targets are set to `gfx942` (MI300).

## Build Instructions

### Quick Start

Use the provided build script for convenience:

```bash
cd /path/to/cp2k/docker
./build_cp2k.sh --clean
```

This will:
- Clean up old containers/images
- Build the CP2K Docker image
- Save build logs to `build.log`

### Manual Build

To build manually:

```bash
cd /path/to/cp2k/docker
docker build -t mycontainer/cp2k:latest .
```

> **Notes:**
> - `mycontainer/cp2k:latest` will be the name of your local container
> - The `.` at the end tells Docker where your build context is located
> - Ensure you're in the `docker` directory (contains `Dockerfile`, `spack.sh`, and `cp2k_environment/`)

### Custom Configuration

To build with custom parameters:

```bash
docker build \
    -t mycontainer/cp2k:latest \
    --build-arg AMDGPU_TARGETS=gfx908,gfx90a \
    --build-arg IMAGE=rocm/dev-ubuntu-24.04:7.0-complete \
    .
```

> **DISCLAIMER**: This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.

### Using Build Cache

For faster rebuilds after making changes:

```bash
# Tag current image
docker tag mycontainer/cp2k:latest mycontainer/cp2k:previous

# Make your changes (edit spack.yaml, package.py, etc.)

# Rebuild using cache
./build_cp2k.sh --cache-from mycontainer/cp2k:previous
```

## Spack Environment Configuration

The CP2K build is controlled by the Spack environment located in `cp2k_environment/`:

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

### Modifying the Build

To change CP2K variants or dependencies:

1. Edit `cp2k_environment/spack.yaml`
2. Modify the `cp2k@2026.1` spec line with desired variants
3. Rebuild the container

Example: To disable a feature, change `+feature` to `~feature` in the spec.

## Build Process Details

The Dockerfile follows these steps:

1. **Base Image Setup**: Installs system packages and development tools
2. **UCX/UCC/OpenMPI**: Builds communication libraries with ROCm support
3. **Spack Installation**: Clones Spack from GitHub
4. **Environment Setup**: Copies `cp2k_environment/` and `spack.sh` into container
5. **Spack Build**: Runs `spack.sh` which:
   - Activates the Spack environment
   - Finds external packages (system-installed tools including GCC from the base image)
   - Concretizes the dependency graph
   - Installs all packages (including CP2K) with 16 parallel jobs
   - Creates symlink `/opt/cp2k` → Spack installation directory

### Build Time

Expected build times:
- Base setup + UCX/UCC/OpenMPI: ~10-15 minutes
- Spack dependency builds: ~20-30 minutes
- CP2K compilation: ~5-10 minutes
- **Total**: ~35-55 minutes (depending on system)

## Run CP2K Container

### Docker

If you want access to any output files generated during the run, add `-v $(pwd):/tmp` before the container name.

#### Docker Interactive

```bash
<<<<<<< cp2k_update
docker run --rm -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --ipc=host \
    -e PMIX_MCA_gds=^ds21 \
    -v $(pwd):/tmp \
    mycontainer/cp2k:latest \
    /bin/bash
=======
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined --ipc=host -e PMIX_MCA_gds=^ds21 mycontainer/cp2k /bin/bash
>>>>>>> main
```

#### Docker Single Command

```bash
docker run --rm \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --ipc=host \
    -e PMIX_MCA_gds=^ds21 \
    -v $(pwd):/tmp \
    mycontainer/cp2k:latest \
    bash -c "cp2k.psmp -i input.inp -o output.out"
```

### CP2K Executables

The container provides CP2K executables via the Spack environment:

- **`cp2k.psmp`**: Parallel SMP (Shared Memory Parallel) version
  - Built with MPI and OpenMP support
  - Includes ROCm GPU acceleration
  - Located at `/opt/cp2k/bin/cp2k.psmp` (also in PATH)

The executable is accessible via:
- Direct path: `/opt/cp2k/bin/cp2k.psmp`
- PATH: `cp2k.psmp` (after sourcing Spack environment)
- Symlink: `/opt/cp2k` → Spack installation directory

### Running Benchmarks

Example benchmark scripts are provided in `scripts/`:

- **`run_dft_nrep2.sh`**: DFT benchmark with 16 MPI ranks
- **`run_rpa32.sh`**: RPA benchmark with two stages (init + solver)
- **`set_cpu_affinity.sh`** and **`set_gpu_affinity.sh`**: Affinity scripts that can be tuned for the system the benchmarks are run on

> **DISCLAIMER**: The affinity scripts (`set_cpu_affinity.sh` and `set_gpu_affinity.sh`) must be tuned according to your specific system configuration to achieve maximum performance. The default settings may not be optimal for all hardware configurations.

To run benchmarks:

```bash
<<<<<<< cp2k_update
cd /path/to/cp2k/docker
./scripts/run_dft_nrep2.sh
=======
docker run --rm --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined --ipc=host -e PMIX_MCA_gds=^ds21 mycontainer/cp2k bash -c "<cp2k Command>"
>>>>>>> main
```

These scripts handle:
- CP2K repository cloning
- CPU/GPU affinity setup
- Output file management

### Singularity

To build a Singularity image from the Docker image:

```bash
singularity build cp2k.sif docker-daemon://mycontainer/cp2k:latest
```

#### Singularity Interactive

```bash
singularity shell --no-home --writable-tmpfs cp2k.sif
```

#### Singularity Single Command

```bash
singularity run --no-home --writable-tmpfs cp2k.sif bash -c "cp2k.psmp -i input.inp -o output.out"
```

## Runtime Options

### GPU-to-GPU Communication (g2g)

To enable GPU-to-GPU communication in DBCSR, set the environment variable:

```bash
export DBCSR_USE_ACC_G2G=1
```

This can improve performance for multi-GPU runs. Example:

```bash
docker run --rm \
    --device=/dev/kfd \
    --device=/dev/dri \
    -e DBCSR_USE_ACC_G2G=1 \
    mycontainer/cp2k:latest \
    bash -c "mpirun -np 16 -x DBCSR_USE_ACC_G2G=1 cp2k.psmp -i input.inp"
```

## Troubleshooting

### Build Failures

If the build fails during Spack installation:

1. Check `build.log` for detailed error messages
2. Verify network connectivity (Spack downloads packages)
3. Ensure sufficient disk space (~25GB+ required)
4. Check that base image has ROCm support

### Missing Executables

If CP2K executable is not found:

```bash
# Inside container
source /opt/spack/share/spack/setup-env.sh
spack env activate /opt/cp2k_environment
which cp2k.psmp
```

### GPU Issues

If GPU is not detected:

- Verify `/dev/kfd` and `/dev/dri` devices exist on host
- Check ROCm installation in base image
- Ensure GPU architecture matches `amdgpu_target` in `spack.yaml`

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
