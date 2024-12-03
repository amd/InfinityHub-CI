# HPCG

| Publisher | Built By | Multi-GPU Support |
| --------- | -------- | ----------------- |
| ICL at U of Tennessee  | AMD      | Yes               |

[HPCG](https://hpcg-benchmark.org/), or the High Performance Conjugate Gradient Benchmark complements the High Performance LINPACK (HPL) benchmark. The computational and
data access patterns of HPCG are designed to closely match a broad set of important applications not represented by HPL, and to incentivize computer system designers to invest in 
capabilities that will benefit the collective performance of these applications. 

## Overview
High Performance Conjugate Gradient (HPCG) Benchmark complements the High Performance LINPACK (HPL) benchmark by introducing computational and data access patterns designed to closely match a broad set of important applications not represented by HPL.

HPCG is a complete, stand-alone code that measures the performance of the individual components of a multi-grid preconditioned conjugate gradient algorithm that exercises the key kernels on a nested set of coarse grids:
- Sparse matrix-vector multiplication
- Vector updates
- Global dot products
- Local symmetric Gauss-Seidel smoother
- Sparse triangular solve (as part of the Gauss-Seidel smoother)

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Building Recipes
[Bare Metal Build](/hpcg/baremetal/)
[Docker/Singularity Build](/hpcg/docker/)

## Running rocHPCG Benchmark

## SYNOPSIS
```
mpirun -n <numprocs> hpcg  <nx> <ny> <nz> <sec> 
```

## DESCRIPTION
HPCG solves the Poisson differential equation discretized with a 27-point stencil on a regular 3D grid using a multi-grid preconditioned conjugate gradient algorithm with a symmetric Gauss-Seidel smoother. It complements HPL as a high performance benchmark by measuring the execution rate of a Krylov subspace solver on distributed memory hardware to represent computations and data access patterns commonly used when solving scientific problems. HPCG is weakly scaled and takes the dimensions `<nx>`, `<ny>`, and `<nz>` of the local grid as its first three input parameters. HPCG will decide how to construct the global problem based on the number of available MPI processes and the aspect ratio of the local domain. HPCG first determines the residual obtained after 50 iterations when solving the problem with a reference computation on the CPU. This residual is used as a convergence criterion for the accelerated algorithm. The benchmark is solved repeatedly as many times as needed to run for the number of seconds specified by the fourth input parameter `<sec>`. Official benchmark runs must run for at least 1800s to capture sustained performance. 

## BASIC ARGUMENTS
For basic usage the following HPCG arguments should suffice

**HPCG arguments:**
```
   <nx>                  First dimension of local grid
   <ny>                  Second dimension of local grid
   <nz>                  Third dimension of local grid
   <sec>                 Target runtime
```
> Note:
>- The dimensions of the grid (`<nx>`,`<ny>`,`<nz>`) must all be multiples of **8** to accommodate three multi-grid coarsening levels.

## EXAMPLE 
An example of running the HPCG application using 8 GPUs and 8 MPI processes, with local grid size of 280&times;280&times;280:
```
mpirun -n 8 hpcg 280 280 280 1800 
```

At the end of each run HPCG reports the performance of individual components as well as the overall performance of the benchmark.  
As an example, consider the following results from a run on 8×MI250:
```
DDOT   =  1952.9 GFlop/s (15623.1 GB/s)     244.1 GFlop/s per process ( 1952.9 GB/s per process)
WAXPBY =   802.7 GFlop/s ( 9632.3 GB/s)     100.3 GFlop/s per process ( 1204.0 GB/s per process)
SpMV   =  1540.3 GFlop/s ( 9690.8 GB/s)     192.5 GFlop/s per process ( 1211.3 GB/s per process)
MG     =  2143.6 GFlop/s (16539.4 GB/s)     268.0 GFlop/s per process ( 2067.4 GB/s per process)
Total  =  1969.5 GFlop/s (14926.3 GB/s)     246.2 GFlop/s per process ( 1865.8 GB/s per process)
Final  =  1949.0 GFlop/s (14771.6 GB/s)     243.6 GFlop/s per process ( 1846.5 GB/s per process)
```
>Note: 
>This is just an example of output format, the values obtained will vary depending on the characteristics of the system.



## Performance Considerations
## Understanding Benchmark Results
HPCG is implemented with GPU-aware communication and should run well out of the box without additional performance tuning.
The main source of performance variation is the iteration count required for convergence which may negatively impact the Figure of Merit (FoM).
The number of iterations required for convergence may be affected by problem size (determined by the dimensions of the grid) and the number of MPI ranks.
If the iteration count exceeds 50, HPCG scales back the FoM (throughput) accordingly.

## Adjusting problem size for device memory
As noted in **BASIC ARGUMENTS**, the grid dimensions must be multiples of **8**.  The total problem size should be large enough to exceed the device cache and can be increased relative to the device memory.  Examples of command line arguments to use for 16 GB of memory on the GPU device:
```
mpirun -n <numprocs> hpcg 280 280 280 1800 
```

And doubling the x dimension (`<nx>`) for a device with 32 GB of memory on the GPU device:
```
mpirun -n <numprocs> hpcg 560 280 280 1800
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
|rocHPCG|BDS 3-Clause|[HPCG](https://github.com/hpcg-benchmark/hpcg) <br /> [rocHPCG](https://github.com/ROCmSoftwarePlatform/rocHPCG) <br /> [rocHPCG License](https://github.com/ROCmSoftwarePlatform/rocHPCG/blob/develop/LICENSE.md)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
