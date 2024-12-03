# Trilinos

## Overview
Trilinos is a portable toolkit for scientific computing developed at Sandia National Laboratory. Trilinos is built on top of the Kokkos portability layer, which means it has support for all manner of architectures using a MPI+X methodology where MPI handles communication between distributed memory spaces, and local compute can be handled using a variety of CPU/GPU parallelization APIs such as OpenMP, CUDA, and HIP, as well as experimental backends including HPX and SYCL, all of which is hidden under the Kokkos abstraction layer.

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Build Recipes
- [Docker/Singularity Build](/trilinos/docker/)

### Running Trilinos Benchmark
The benchmark provided in this container uses the MiniEM mini-app which is an unstructured electromagnetics solver built around an exact sequence discretization (edge/face basis functions) that uses Trilinos' algebraic multigrid (AMG) preconditioned conjugant gradient (CG) solver through MueLu. The default configuration defined by this container is to run a 25&times;25&times;25 hexahedral mesh over 100 time steps. The benchmark will report a figure-of-merit (FOM) in terms of the cell updates per second. The reported FOM will ignore initialization and setup time.

The benchmark can be found in the `/opt/trilinos/example/PanzerMiniEM/` directory. The executable `PanzerMiniEM_BlockPrec.exe` can be queried with `-h` for more information on the benchmark. The `maxwell.xml` file located in the executable directory contains various parameters that can be used to tune the benchmark.

The following command is an example of running the MiniEM benchmark in interactive mode (see: [docker build instructions](/trilinos/docker/README.md)):
```
cd /opt/trilinos/example/PanzerMiniEM/
mpirun -n <NumGPU> ./PanzerMiniEM_BlockPrec.exe --x-elements=25 --y-elements=25 --z-elements=25 --numTimeSteps=100 --workset-size=20000 --kokkos-map-device-id-by=mpi_rank
```

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
|Trilinos|BSD 3-Clause, LGPL|[Trilinos](https://github.com/trilinos/Trilinos)<br >[Trilinos License](https://trilinos.github.io/license.html)|
|HDF5|BSD-like(CUSTOM)|[HDF5 License](https://github.com/HDFGroup/hdf5/blob/develop/COPYING)|
|ZLIB|MIT|[ZLIB License](https://github.com/madler/zlib?tab=License-1-ov-file#readme)|
|PNetCDF|CUSTOM|[PNetCDF License](https://github.com/Parallel-NetCDF/PnetCDF/blob/master/COPYRIGHT)|
|NetCDF-c|BSD-3-Clause|[NEtCDF-c License](https://github.com/Unidata/netcdf-c?tab=BSD-3-Clause-1-ov-file#readme)|
|Matio|BSD-2-Clause|[Matio License](https://github.com/tbeu/matio?tab=BSD-2-Clause-1-ov-file#readme)|
|Boost|BSL-1 License|[Boost License](https://github.com/boostorg/boost?tab=BSL-1.0-1-ov-file#readme)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.
