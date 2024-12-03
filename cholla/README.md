# Cholla

## Overview
Cholla is a static-mesh, GPU-native hydrodynamics simulation code that efficiently runs high-resolution simulations on massively-parallel computers. The code is written in a combination of C++, Cuda C, and HIP, and requires at least one AMD GPU to run. 

Cholla (Computational Hydrodynamics On ParaLLel Architectures) is a 3D GPU-based hydrodynamics code (Schneider & Robertson, ApJS, 2015). Cholla is designed to be run using (AMD or NVIDIA) GPUs, and can be run in serial mode using one GPU or with MPI for multiple GPUs. 

The source code is available on [github](https://github.com/cholla-hydro/cholla/). Cholla was designed for astrophysics simulations, and the current release includes the following physics:
- compressible hydrodynamics in 1, 2, or 3 dimensions
- optically-thin radiative cooling and photoionization heating, including the option to use the Grackle cooling library
- static gravity with user-defined functions
- FFT-based gas self-gravity
- particle-mesh based particle gravity
- cosmology
- passive scalar tracking

Cholla can be run using a variety of different numerical algorithms, allowing users to test the sensitivity of their results to the exact code configuration. Options include:
- Exact, Roe, and HLLC Riemann solvers
- 2nd and 3rd order spatial reconstruction with limiting in either primitive or conserved variables
- a second order Van Leer integrator

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Build Recipes
- [Bare Metal Build](/cholla/baremetal/)
- [Docker/Singularity Build](/cholla/docker/)

## Running Cholla Benchmarks
These examples are using the [Cholla Docker Build](/cholla/docker/), which build the binary file cholla.gravity.cholla-container based on environment variable `CHOLLA_MACHINE` set to `cholla-container` and was build/installed into `/opt/cholla`. 

Cholla has many examples within the project, `/path/to/cholla/examples/`, find the benchmark that you wish to run in there, or provide your own workload.   

You can run the examples using the command syntax below, where `#` is the number of GPUs to use and `<benchmark-to-run>` should be replaced with the full file path to the load details. 

```
mpirun -np # cholla.gravity.cholla-container <benchmark-to-run>
```
### Examples 
* 4 GPU 3D sound wave
```
mpirun -np 4 cholla.gravity.cholla-container /opt/cholla/examples/3D/sound_wave.txt
```
* 8 GPU 3D Sound wave
```
mpirun -np 8 cholla.gravity.cholla-container /opt/cholla/examples/3D/sound_wave.txt
```
* 4 GPU 3D sod<br> 
```
mpirun -np 4 cholla.gravity.cholla-container /opt/cholla/examples/3D/sod.txt
```
* 8 GPU 3D sod<br> 
```
mpirun -np 8 cholla.gravity.cholla-container /opt/cholla/examples/3D/sod.txt
```

Each MPI rank will bind to a particular unique GPU (1 rank per device) and strong-scale the problem accordingly. Please define `HIP_VISIBLE_DEVICES` to control which particular GPUs are available to Cholla. 


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
|Cholla|MIT|[Cholla](https://github.com/cholla-hydro/cholla)<br >[Cholla License](https://github.com/cholla-hydro/cholla/blob/main/LICENSE.txt)|
|HDF5|BSD-like(CUSTOM)|[HDF5 License](https://github.com/HDFGroup/hdf5/blob/develop/COPYING)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
