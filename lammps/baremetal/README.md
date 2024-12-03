

## LAMMPS Bare Metal Build Instructions for AMD Machine Instinct GPUs using Kokkos/HIP

## Overview
This document gives guidance on how to build the Kokkos backend of LAMMPS for AMD Machine Instinct GPUs using HIP, e.g., the MI250X, MI250, MI210, MI100, and MI50.
This document is not comprehensive, and is primarily intended to be a starting point to enable builds of additional packages and modes.
For more details on how to build LAMMPS, the user is referred to [the official LAMMPS documentation](https://docs.lammps.org/Build.html), in particular for the [Kokkos backend](https://docs.lammps.org/Build_extras.html#kokkos).


## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver |
| ---- | ---- | ----------------- | ------------ |
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 |  <br> ROCm v6.x compatibility |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)


## System Dependencies
|Application|Minimum|Recommended|
|---|---|---|
|Git|Latest|Latest|
|ROCm|5.3.0|latest|
|OpenMPI|4.0.3|5.0.2|
|UCX|1.8.0|1.16.0|
|CMAKE|3.22.2|Latest|

## Installing LAMMPS
The below is an example of a simple build from the latest stable version of LAMMPS (the recommended code-source).

1. Validate the Cluster/System has all of the above applications, with system path, library, and include environments set correctly. If you are unsure, the [Dockerfile](/lammps/docker/Dockerfile) has examples of all useful configurations listed after the `ENV` commands. 

2. Clone [LAMMPS GIT repo](https://github.com/lammps/lammps.git) into your workspace. 
> Recommended Branch: `patch_27Jun2024`
```bash
git clone -b patch_27Jun2024 https://github.com/lammps/lammps.git
```

3. Create Build directory
Create a Build directory where you would like the LAMMPS binaries to be located. 
> Update  `<path/to/lammps>` and `<path/to/lammps_install>`  to match where you have cloned and install location respectively in the following commands. 
> Update which GPU Kokkos will build for by adding/removing the `-DKokkos_ARCH_VEGAXXX=on` flag. Currently building for MI200. 

```
mkdir -p </path/to/lammps>/build
cd </path/to/lammps>/build
```

And run the install command from that directory:
```bash
cmake   -DPKG_KOKKOS=on \
        -DPKG_REAXFF=on \
        -DPKG_MANYBODY=on \
        -DPKG_ML-SNAP=on \
        -DPKG_MOLECULE=on \
        -DPKG_KSPACE=on \
        -DPKG_RIGID=on \
        -DBUILD_MPI=on \
        -DMPI_CXX_SKIP_MPICXX=on \
        -DFFT_KOKKOS=HIPFFT \
        -DCMAKE_INSTALL_PREFIX=/<path-to-install>/lammps \
        -DMPI_CXX_COMPILER=$(which mpicxx) \
        -DCMAKE_BUILD_TYPE=Release \
        -DKokkos_ENABLE_HIP=on \
        -DKokkos_ENABLE_SERIAL=on \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_COMPILER=$(which hipcc) \
        -DKokkos_ARCH_VEGA90A=ON \
        -DKokkos_ENABLE_HWLOC=on \
        -DLAMMPS_SIZES=smallbig \
        -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON \
        -DCMAKE_CXX_FLAGS="-munsafe-fp-atomics" \
        ../lammps/cmake
make -j$(nproc) install
```

4. (Optional) Adding LAMMPS to PATH:
```
export PATH=<path/to/lamps_install>/bin:$PATH
```

## In this build example uses:
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

## Alternate build methods

In addition, we note that `LAMMPS` provides `CMake` presets for `Kokkos-HIP` compilation, supplied in [cmake/presets](https://github.com/lammps/lammps/blob/develop/cmake/presets/kokkos-hip.cmake).
LAMMPS provides instructions on the [use of these presets](https://docs.lammps.org/Build_extras.html#kokkos-package) in the Kokkos build section of the documentation.
This build mode is very close to the instructions provided above, but we have chosen to explicitly outline the `CMake` configuration step to enable easier extension for different use cases.


## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|LAMMPS|GPLv2.0|[LAMMPS](https://www.lammps.org/)<br /> [LAMMPS License](https://docs.lammps.org/Intro_opensource.html)|
|NumPy|BSD 3-clause|[NumPy License](https://github.com/numpy/numpy/blob/main/LICENSE.txt)|
|PANDAS|BSD 3-clause|[PANDAS license](https://github.com/pandas-dev/pandas/blob/main/LICENSE)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Notices and Attribution
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## License and Attributions

© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
