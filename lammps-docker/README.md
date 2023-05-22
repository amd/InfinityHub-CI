# LAMMPS

## Overview
The Large-scale Atomic/Molecular Massively
Parallel Simulator (LAMMPS) is a classical molecular dynamics code for materials modeling. It is capable of modeling 2d or 3d systems composed of only a few up to billions of particles. The code is primarily designed to run in parallel computers that support the Message Passing Interface (MPI) library and spatial decomposition of the simulation domain.  

This document provides build recipes for running LAMMPS on AMD Instinct GPUs via the Kokkos backend.

LAMMPS is distributed as an [open source code](https://docs.lammps.org/Intro_opensource.html) under the terms of the GPLv2. The current version of LAMMPS can be downloaded [here](https://lammps.sandia.gov/download.html). Links to older versions are also included. All LAMMPS development is done via [GitHub](https://github.com/lammps/lammps), so all versions can also be accessed there. Periodic releases are also posted to SourceForge.

More information about LAMMPS can be found in the [LAMMPS Website](https://www.lammps.org/#gsc.tab=0) and in the [LAMMPS Manual](https://docs.lammps.org/Manual.html).

## Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> AMD Instinct MI50 GPU(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility |[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://docs.amd.com/)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [Testing the ROCm Installation](https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html#testing-the-rocm-installation)

## LAMMPS build instructions for AMD Machine Instinct GPUs using Kokkos/HIP

This document gives guidance on how to build the Kokkos backend of LAMMPS for AMD Machine Instinct GPUs using HIP, e.g., the MI250X, MI250, MI210, MI100, and MI50.
This document is not comprehensive, and is primarily intended to be a starting point to enable builds of additional packages and modes.
For more details on how to build LAMMPS, the user is referred to [the official LAMMPS documentation](https://docs.lammps.org/Build.html), in particular for the [Kokkos backend](https://docs.lammps.org/Build_extras.html#kokkos).

### Prerequisites

This document assumes the following pre-requisites:
  - Standard build tools (cmake) available and installed on the $PATH
  - MPI (preferably with GPU-Aware ROCm support), compiled and installed on the $PATH
    - For more details see the: [OpenMPI + UCX GPU-Aware MPI ROCm recipe](/base-gpu-mpi-rocm-docker)
  - ROCm is installed, and hipcc is available on the $PATH

### Build instructions for LAMMPS (bare metal)

The below is an example of a simple build from the latest stable version of LAMMPS (the recommended code-source):

```bash
git clone https://github.com/lammps/lammps.git
pushd lammps
git checkout stable_23Jun2022_update3
popd
mkdir build
pushd build
cmake -DPKG_KOKKOS=on \
  -DPKG_REAXFF=on \
  -DPKG_MANYBODY=on \
  -DPKG_ML-SNAP=on \
  -DBUILD_MPI=on \
  -DCMAKE_INSTALL_PREFIX=../install \
  -DMPI_CXX_COMPILER=$(which mpicxx) \
  -DCMAKE_BUILD_TYPE=Release \
  -DKokkos_ENABLE_HIP=on \
  -DKokkos_ENABLE_SERIAL=on \
  -DCMAKE_CXX_STANDARD=14 \
  -DCMAKE_CXX_COMPILER=$(which hipcc) \
  -DKokkos_ARCH_VEGA90A=ON \
  -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON \
  -DCMAKE_CXX_FLAGS=-munsafe-fp-atomics \
  ../lammps/cmake
make -j$(nproc) install
popd
export PATH=$(realpath ./install/bin):$PATH
```

### In this build example, we:

  - Turn on the Kokkos backend via [`DPKG_KOKKOS`](https://docs.lammps.org/Packages_details.html#pkg-kokkos), and select `HIP` for the device (`Kokkos_ENABLE_HIP`).
    - We could optionally choose to enable `OpenMP` support for the host via `Kokkos_ENABLE_OPENMP`.
  - Turn on a handful of commonly used packages: [`REAXFF`](https://docs.lammps.org/Packages_details.html#pkg-reaxff), [`MANYBODY`](https://docs.lammps.org/Packages_details.html#pkg-manybody), [`ML-SNAP`](https://docs.lammps.org/Packages_details.html#pkg-ml-snap), for various benchmarks.
    - If the user attempts to run a code that requires an additional package, [`LAMMPS` will typically error at runtime](https://docs.lammps.org/Build_package.html#include-packages-in-build) with an error saying that a command or style is unknown.
    - Additional packages can be enabled in LAMMPS via the standard `-DPKG_<Package Name>=on` cmake options. For example, the following options enable the [LAMMPS molecule package](https://docs.lammps.org/Packages_details.html#pkg-molecule): `-DPKG_MOLECULE=on` `-DPKG_KSPACE=on` `-DPKG_RIGID=on`
  - Enable `MPI` support, using the `mpicxx` on the path as the `MPI_CXX` compiler.
    - The above assumes an MPI with a standard `mpicxx`-type wrapper. Instructions may differ for systems with other MPI-stacks without this type of wrapper (e.g., Cray/HPE), 
  - Enable `Kokkos-HIP` support, using `hipcc` on the path as the `CXX` compiler (this is also used to compile `HIP` code)
  - Enable MI250X/250/210 support via the `VEGA90A` arch.  For other MI cards different Kokkos arch's should be used as [detailed by Kokkos](https://kokkos.github.io/kokkos-core-wiki/keywords.html#architecture-keywords).
    - Optionally, compilation flags for specific CPU archictures can be specified as [detailed by Kokkos](https://kokkos.github.io/kokkos-core-wiki/keywords.html#architecture-keywords)
  - Enabling a handful of key optimization flags (`HIP_MULTIPLE_KERNEL_INSTANTIATIONS` and `munsafe-fp-atomics`) 

### Alternate build methods

In addition, we note that `LAMMPS` provides `CMake` presets for `Kokkos-HIP` compilation, supplied in [cmake/presets](https://github.com/lammps/lammps/blob/develop/cmake/presets/kokkos-hip.cmake).
LAMMPS provides instructions on the [use of these presets](https://docs.lammps.org/Build_extras.html#kokkos-package) in the Kokkos build section of the documentation.
This build mode is very close to the instructions provided above, but we have chosen to explicitly outline the `CMake` configuration step to enable easier extension for different use cases.

## Building a Docker container for LAMMPS

Download the [Dockerfile](/lammps-docker/Dockerfile)  

To run the default configuration:
```
docker build -t mycontainer/lammps -f /path/to/Dockerfile . 
```
>Notes:
>- `mycontainer/lammps` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context, if you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/lammps \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm/dev-ubuntu-20.04:5.2.3-complete \
    --build-arg LAMMPS_BRANCH=stable_23Jun2022_update3 \
    --build-arg UCX_BRANCH=master \
    --build-arg OMPI_BRANCH=main \
    . 
```

## Running the LAMMPS Container
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

### Docker
To run the container interactively, run the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/lammps  bash
```
and launch any LAMMPS command from the prompt. 

For non-interactive runs, simply replace `bash` with the run command:

```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           mycontainer/lammps  \
           <lammps run command>
```
### Singularity

To create a Singularity container from your local Docker container, run the following command:
```
singularity build lammps.sif  docker-daemon://mycontainer/lammps:latest
```

Singularity can be used in a similar way to Docker to launch interactive and non-interactive containers, as shown in the following example of launching a non-interactive run:
```
singularity exec  --no-home --pwd /benchmark lammps.sif <lammps run command>
```
## Sample run commands

In this section, we provide a couple of examples from the set of [LAMMPS standard benchmarks](https://docs.lammps.org/Speed_bench.html), intended to guide users when constructing their own run commands tailored to their specific workload(s).

In these examples, the input to the run command is provided via an input file. Other inputs may have additional parameters that can be modified and may change performance. 

Additionaly, we have supplied several arguments such as `cuda/aware on` which modify the behavior of LAMMPS, in this case, forcing enablement of GPU-aware communications. For additional run options, see [Running LAMMPS with the KOKKOS package](https://docs.lammps.org/Speed_kokkos.html#running-lammps-with-the-kokkos-package). 
Note that the use of `neigh full' in the run command triggers the use of full neighbor-lists, as described [here](https://docs.lammps.org/Developer_par_neigh.html).

For convenience, we also added the installed binary path (`install/bin`) to the PATH environment variable (see bare metal build instructions above) so that the lmp binary can be found when running the benchmark examples.

- Run EAM benchmark on eight GPUs

The following command runs the EAM benchmark using a x/y/z size of 1/1/1, as defined by the [input file](https://github.com/lammps/lammps/blob/develop/bench/in.eam).
```
mpirun --mca pml ucx --mca btl ^vader,tcp,openib,uct -np 8 lmp -k on g 8 -sf kk -pk kokkos cuda/aware on neigh half comm device -v x 1 -v y 1 -v z 1 -in in.eam -nocite -log log.lammps
```
- Run LJ benchmark on one GPU

The following command runs the LJ benchmark using a x/y/z of size 8/8/8. Note that we have chosen to run a larger problem size than specified in the sample [input file](https://github.com/lammps/lammps/blob/develop/bench/in.lj). The user may wish to experiment with problem sizes and other run otions to achieve optimal performance.

```
mpirun --mca pml ucx --mca btl ^vader,tcp,openib,uct -np 1 lmp -k on g 1 -sf kk -pk kokkos cuda/aware on neigh full -v x 8 -v y 8 -v z 8  -in in.lj -nocite -log log.lammps
```

## Licensing Information

Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components: Ubuntu (License: Creative Commons CC-BY-SA version 3.0 UK licence), LAMMPS (License: GPL v2.0 or at your option, any later version), CMAKE (License: BSD 3), numpy (License: BSD 3-clause), PANDAS (License: BSD 3 + Restrictions), OpenMPI (License: BSD 3-Clause), OpenUCX (License: BSD 3-Clause), ROCm (License: Custom/MIT/Apache V2.0/UIUC OSL). Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Notices and Attribution

The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.
 
## License and Attributions

© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
