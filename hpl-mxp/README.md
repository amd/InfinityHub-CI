# rocHPL-MxP

## Overview
HPL-MxP solves a dense linear system of equations by using a low-precision LU factorization followed by iterative refinement. Similar to HPL, its more famous cousin, HPL-MxP uses a processor grid for load balancing across MPI ranks. The matrix of size N is tiled into blocks of size B which are cyclically distributed across a processor grid with P rows and Q columns. P is an explicit input argument while Q is deduced from P and the total number of MPI ranks, i.e. Q = n/P. HPL-MxP requires that P is a multiple of the number of MPI ranks n, and that matrix size N is a multiple of block size B.

> **NOTE**  
> formally known as HPL-AI (Accelerator Introspection)
## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 


## Building Recipes
[Docker/Singularity Build](/hpl-mxp/docker/)

## Running rocHPL-MxP Benchmark
HPL-MxP reports the apparent FLOPS associated with the direct solve of a dense linear system.

`FLOPS = (2/3N^3 + 3/2N^2)/runtime`

In reality, the number of FLOPS is somewhat higher as additional operations take place in the iterative refinement steps required to bring the accuracy of the solution to double precision. HPL-MxP also reports the residual at the end of the refinement steps to allow the user to verify that double precision accuracy has been obtained.

In general, HPL-MxP performance will increase with matrix size and the benchmark is typically scaled so that the global matrix fills most of the available GPU memory. Optimal parameters depend on the system. Examples of parameters on AMD Instinct GPUs:

### MI100
- 1 GPU:  
```mpirun_rochplmxp -P 1 -Q 1 -N 81920 --NB 2560```
- 2 GPUs:  
```mpirun_rochplmxp -P 2 -Q 1 -N 122880 --NB 2560```
- 4 GPUs:  
```mpirun_rochplmxp -P 2 -Q 2 -N 168960 --NB 2560```
- 8 GPUs:  
```mpirun_rochplmxp -P 4 -Q 2 -N 235520 --NB 2560```


### MI210/MI250/MI250X
- 1 GPU:  
```mpirun_rochplmxp -P 1 -Q 1 -N 125440 --NB 2560```
- 2 GPUs:  
```mpirun_rochplmxp -P 2 -Q 1 -N 179200 --NB 2560```
- 4 GPUs:  
```mpirun_rochplmxp -P 2 -Q 2 -N 250880 --NB 2560```
- 8 GPUs:  
```mpirun_rochplmxp -P 4 -Q 2 -N 358400 --NB 2560```


For a complete list of hpl-mxp arguments, see [rocHPL-MxP GitHub Repo](https://github.com/ROCm/rocHPL-MxP)

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
|MIT|BSD 3-Clause, LGPL|[hpl-mxp](https://hpl-mxp.org)<br >|



Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
