# PETSc

## Overview
PETSc, the Portable, Extensible Toolkit for Scientific Computation, pronounced PET-see (the S is silent), is a suite of data structures and routines for the scalable (parallel) solution of scientific applications modeled by partial differential equations. It supports MPI, and GPUs through CUDA, HIP or OpenCL, as well as hybrid MPI-GPU parallelism; it also supports the NEC-SX Tsubasa Vector Engine. PETSc (sometimes called PETSc/TAO) also contains the TAO, the Toolkit for Advanced Optimization, software library.

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 


For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Building Recipes
[Docker/Singularity Build](/petsc/docker/)

## Running PETSc Benchmark
A 3D Poisson Solve is included with the source code and is designed to assess the performance characteristics of PETSc library. As of now, the benchmark can be located in the `src/ksp/ksp/tutorials/` directory, within the [PETSc GIT repository](). This Script [run-benchmark.sh](/petsc/docker/benchmark/run-benchmark.sh) can be used to build and run the benchmark. It is included in the [PETSc Docker image](/petsc/docker/).

For the `run-benchmark.sh` bash script included here, the usage can be found by adding the `-h` which prints the different arguments that can be passed to the script. For example:

```
./run-benchmark.sh -h
```
will print the usage as: 
```
This script is designed to setup and run PETSc ksp_performance (3D Poisson Solve) benchmark on GPUs.
=================================
usage: ./run-benchmark.sh

       -h | --help      Prints the usage
       -c | --clean     Clean the case directory
       -r | --run-only  skip build, and directly run the benchmark
       -g | --ngpus     #GPUs to be used (between 1-10), defaults to 1
       -d | --gpu-support support for GPU offloading (e.g.: HIP or CUDA)
       -l | --log-view  Enables -log_view to see more details at end of PETSc solve
       -n | --mat-size  Prescribe a Mat size (e.g -n 200 will select a 200^3 matrix)
       -pc| --pc-type   Prescribe custom options for preconditioner
                        (default -pc_type bjacobi and -sub_pc_type ilu)
       -ksp|--ksp-options Prescribe custom options for KSP solvers
```
The `run-benchmark.sh` script configures and sets some parameters to run the PETSc benchmark (`bench_kspsolve`) on GPUs. A description of these parameters is included below for reference: 

| parameters| description/options   |
| --------- | --------------------- |
| -vec_type | type of backend (CPU/GPU) for **vec** class. <br> Options: <br> `seq` for single CPU-only, `mpi` for multiple-CPU <br> `hip` for single or multiple AMD GPUs with HIP <br> Similar `cuda`, `kokkos` available for CUDA and Kokkos.|
| -mat_type | type of backend (CPU/GPU) for **mat** class. <br> Options: <br> `aij` for single CPU-only, `mpiaij` for multiple-CPU <br> `aijhipsparse` for single or multiple AMD GPUs with HIP <br> Similar `aijcusparse`, `aijkokkos` available for CUDA and Kokkos.|
| -pc_type  | preconditioner type. E.g. `ilu`, `gamg`, etc. |
| -ksp_type | Krylov subspace method type. E.g. `cg`, `gmres`, etc. |

A full list of tuneable parameters and configurations can be found in PETSc [documentation](https://petsc.org/release/docs/manual/).

To run the benchmark on 1 GPU using the bash script, use the command:
```
./run-benchmark.sh -g 1
```
> NOTE
> * If the `-g` is not mentioned in commands above, by default the script will use 1 GPU. But for consistency, we recommend always adding the `-g` to prescribe #GPUs.
> * The number of GPUs can be altered to run on multiple GPUs. When #GPUs>1, the number of MPI ranks used will be equal to the number of GPUs. For example, when launched with 4 GPUs, 4 MPI ranks will be deployed. The script will automatically  adjust the MPI ranks to the number of GPUs.
> * It must be noted that the script is designed to run on a maximum of 10 GPUs at a time, and will require alteration if #GPUs>10 need to be used. One can also assign multiple-MPI ranks to each GPU, however that is not included in these bash scripts.
> * Problem size is define by the cube dimension, which can be varied using the `-n` option. By default the script uses `-n 200`, but a customized dimension can be provided with:
> ```
> ./run-benchmark.sh -g 1 -n 100
> ```
> * The KSP solver options and preconditioner type can be changed using the `-ksp` and `-pc` options respectively, and providing a string of options inside `""`. Default options are set by the `run-benchmark.sh` script. For example to use the `-pc_type gamg` preconditioner type, one can specify:
> ```
> ./run-benchmark.sh -g 1 -n 100 -pc "-pc_type gamg"
> ```
> * `-l` dumps a log at the end of the PETSc run and can be useful to investigate the statistics. To enable this, use the command: 
> ```
> ./run-benchmark.sh -g 1 -n 100 -pc "-pc_type gamg" -l
> ```

The benchmark script prints the result to the screen/terminal. A sample output can look like:
```
Running the benchmark with single GPU
===========================================
Test: KSP performance - Poisson
        Input matrix: 27-pt finite difference stencil
        -n 200
        DoFs = 8000000
        Number of nonzeros = 213847192

Step1  - creating Vecs and Mat...
Step2  - running KSPSolve()...
Step3  - calculating error norm...

Error norm:    1.375e+00
KSP iters:     103
KSPSolve:      4.65297 seconds
FOM:           1.719e+06 DoFs/sec
===========================================
```
## Performance Considerations
PETSc has not previously provided a benchmark for performance evaluation, but the current benchmark was recently introduced to facilitate comparisons of performance as parameters and hardware are varied.  The figure of merit (FoM) used by the Poisson Solve benchmark is "Degrees of Freedom per second" (DoF/sec), with a larger DoF/sec indicating better performance.

PETSc examples in general have nearly infinite combinations of parameters (e.g., `-ksp_type`, `-pc_type`, `-ksp_rtol`, etc) suited for particular situations. For this particular performance benchmark the main parameter to tune is the cube dimension, specified with the `-n`parameter, e.g.: `-n <cube_dim>`.  The total number of degrees of freedom (aka cube size) is the value `-n <cube_dim>` cubed. The default value is **200** or 1e6 degrees of freedom. These guidelines should be followed:
 
1. The cube dimension should "saturate" hardware utilization.
1. Use the same cube dimension when comparing across different hardware.
1. Error norm should be the same for a given dimension and concurrency.
 
## Cube Dimension Guidance
Regarding the dimension to use to "saturate" hardware utilization, PETSc developers recommend using a "work-time spectrum" analysis to identify the range of optimal problem sizes for a particular solver.  In other words, with a fixed concurrency (e.g., _X_ GPUs) you incrementally increase the cube dimension (using `-n <cube_dim>`) until you see the DOF/Sec remain consistent. A dimension too small you'll likely see a small FoM because of low GPU utilization; a dimension too large you'll also see a small FoM either because of hardware limitations (e.g., cache misses) or suboptimal algorithmic convergence of the solver.
 
For example, for a single MI210 GPU a cube dimension around 200 will typically "saturate" hardware utilization, so testing with a range of 100 to 500 should confirm a value that is optimal for a test system with 1 MI210.  Ensure that the global cube size is large enough so that multiple GPUs and/or nodes still process an optimal subset of the cube.
 
Different hardware may have different "optimal" regions.  For a fair comparison of hardware devices, pick a cube dimension that universally "saturates" all the devices being compared.


## Licensing Information 
Your use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application. 

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|PETSc|BSD-2 Clause | [PETSc License](https://petsc.org/release/install/license/)|
|Scotch|CeCILL-C|[Scotch Web Page](https://www.labri.fr/perso/pelegrin/scotch/)<br /> [Scotch License](https://gitlab.inria.fr/scotch/scotch/-/blob/master/LICENSE_en.txt)|
|HYPRE|Apache V2.0/MIT|[HYPRE Licenses](https://github.com/hypre-space/hypre#license)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER. 

## Disclaimer  
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.   

## Notices and Attribution  
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.  
Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.  Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.    

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.   


