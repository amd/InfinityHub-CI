# PeleC

## Overview
PeleC: An adaptive mesh refinement solver for compressible reacting flows.

For more info checkout the [PeleC Documentation](https://amrex-combustion.github.io/PeleC/).

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Building Recipes
[Docker/Singularity Build](/pelec/docker/)


## Running PeleC Benchmarks
The docker image provided we build for the `drm19` and `doecane_lu` examples. 
Replace the `<numGPUs>` in the follow examples, with the number of GPUs for the examples. 

### drm19 : small chemistry model (21 species)
```
mpirun -n <numGPUs> ./PeleC3d.hip.MPI.HIP.ex.drm19  \
    pmf-drm19-cvode.inp                     \
    geometry.prob_lo=0. 0. 1.               \
    geometry.prob_hi=5.0 5.0 6.0            \
    amr.n_cell=128 128 128                  \
    max_step=25                             \
    amrex.the_arena_init_size=48000000000   
```

### dodecane_lu: medium sized chemistry model (53 species)
```
mpirun -n <numGPUs> ./PeleC3d.hip.MPI.HIP.ex.dodecane_lu    \
    pmf-dodecane_lu-cvode.inp                       \
    geometry.prob_lo=0. 0. 1.                       \
    geometry.prob_hi=5.0 5.0 6.0                    \
    amr.n_cell=128 128 128                          \
    max_step=10                                     \
    amrex.the_arena_init_size=60000000000           \
    prob.standoff=-1.0
```

> **NOTE:** 
> When running using MI300A the following parameter should be added `ode.atomic_reductions=0`
> This parameter is useful for both chemistry models. 


## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any sub-component in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|PeleC|Custom|[Pele Suite](https://amrex-combustion.github.io/)<br />[PeleC License](https://github.com/AMReX-Combustion/PeleC?tab=License-1-ov-file)|
|PelePhysics|Custom|[Pele Suite](https://amrex-combustion.github.io/)<br />[PelePhysics License](https://github.com/AMReX-Combustion/PelePhysics?tab=License-1-ov-file)|
|AMReX|AMReX Copyright|[AMReX](https://github.com/AMReX-Codes)<br />[AMReX License](https://github.com/AMReX-Codes/amrex?tab=License-1-ov-file)|
|SUNDIALS|BSD 3-Clause| [SUNDIALS](https://github.com/LLNL/sundials/)<br />[SUNDIALS License](https://github.com/LLNL/sundials?tab=License-1-ov-file)|



Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
