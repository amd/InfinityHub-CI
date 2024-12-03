# LAMMPS

## Overview
The Large-scale Atomic/Molecular Massively
Parallel Simulator (LAMMPS) is a classical molecular dynamics code for materials modeling. It is capable of modeling 2d or 3d systems composed of only a few up to billions of particles. The code is primarily designed to run in parallel computers that support the Message Passing Interface (MPI) library and spatial decomposition of the simulation domain.  

This document provides build recipes for running LAMMPS on AMD Instinct GPUs via the Kokkos backend.

LAMMPS is distributed as an [open source code](https://docs.lammps.org/Intro_opensource.html) under the terms of the GPLv2. The current version of LAMMPS can be downloaded [here](https://lammps.sandia.gov/download.html). Links to older versions are also included. All LAMMPS development is done via [GitHub](https://github.com/lammps/lammps), so all versions can also be accessed there. Periodic releases are also posted to SourceForge.

More information about LAMMPS can be found in the [LAMMPS Website](https://www.lammps.org/#gsc.tab=0) and in the [LAMMPS Manual](https://docs.lammps.org/Manual.html).

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Build Recipes
- [Bare Metal build](/lammps/baremetal/)
- [Docker/Singularity Build](/lammps/docker/)

## Running LAMMPS Benchmarks

In this section, we provide a couple of examples from the set of [LAMMPS standard benchmarks](https://docs.lammps.org/Speed_bench.html), intended to guide users when constructing their own run commands tailored to their specific workload(s).

In these examples, the input to the run command is provided via an input file. Other inputs may have additional parameters that can be modified and may change performance. 

Additionally, we have supplied several arguments such as `cuda/aware on` which modify the behavior of LAMMPS, in this case, forcing enablement of GPU-aware communications. For additional run options, see [Running LAMMPS with the KOKKOS package](https://docs.lammps.org/Speed_kokkos.html#running-lammps-with-the-kokkos-package). 
Note that the use of `neigh full' in the run command triggers the use of full neighbor-lists, as described [here](https://docs.lammps.org/Developer_par_neigh.html).

For convenience, we also added the installed binary path (`install/bin`) to the PATH environment variable (see bare metal build instructions above) so that the lmp binary can be found when running the benchmark examples.

- Run EAM benchmark on eight GPUs

The following command runs the EAM benchmark using a x/y/z size of 1/1/1, as defined by the [input file](https://github.com/lammps/lammps/blob/develop/bench/in.eam).
```
mpirun --mca pml ucx --mca btl ^vader,tcp,openib,uct -np 8 lmp -k on g 8 -sf kk -pk kokkos cuda/aware on neigh half comm device -v x 1 -v y 1 -v z 1 -in in.eam -nocite -log log.lammps
```
- Run LJ benchmark on one GPU

The following command runs the LJ benchmark using a x/y/z of size 8/8/8. Note that we have chosen to run a larger problem size than specified in the sample [input file](https://github.com/lammps/lammps/blob/develop/bench/in.lj). The user may wish to experiment with problem sizes and other run options to achieve optimal performance.

```
mpirun --mca pml ucx --mca btl ^vader,tcp,openib,uct -np 1 lmp -k on g 1 -sf kk -pk kokkos cuda/aware on neigh full -v x 8 -v y 8 -v z 8  -in in.lj -nocite -log log.lammps
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
