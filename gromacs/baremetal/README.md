# AMD's Implementation of GROMACS with HIP Bare Metal Build Instructions

## Overview
This document provides instructions on how to do a bare metal install of AMD's Implementation of GROMACS with HIP in a Linux environment. 

## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver |
| ---- | ---- | ----------------- | ------------ |
| X86_64 CPU(s) | AMD Instinct MI350 GPU(s) <br> AMD Instinct MI300 GPUS(s) <br> AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility <br> ROCm v6.x compatibility |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)



## System Dependencies
|Application|Minimum|Recommended|
|---|---|---|
|Git|Latest|Latest|
|ROCm|5.3.0|latest|
|CMAKE|3.28.0|Latest|
|OpenMPI (Optional)|4.0.3|5.0.7|
|UCX (Optional)|1.13.0|1.19.0|


## Installing AMD's Implementation of GROMACS with HIP
1. Validate the Cluster/System has all of the above applications, with system path, library, and include environments set correctly. If you are unsure, the [Dockerfile](/gromacs/docker/Dockerfile) has examples of all useful configurations listed after the `ENV` commands. 
2. Clone the [GROMACS repository](https://gitlab.com/gromacs/gromacs.git) into your workspace. Use the 4947-hip-feature-enablement feature enablement branch to use the version with all supported features enabled.. 
```
git clone -b 4947-hip-feature-enablement https://gitlab.com/gromacs/gromacs.git

```
3. Navigate to the `gromacs` folder and create a build folder within the workspace to build the code in. 
```bash
cd gromacs
mkdir build
cd build
```

4. Run cmake command. The variable `OPEN_MPI_ENABLED` has been included, please set it accordingly. By default GROMACS will build for a number of current AMD CDNA and RDNA architectures. You can change this by setting the `GMX_HIP_TARGET_ARCH` variable to the exact architecture you want to build for
>- Threaded MPI (Recommended): `off`
>- For OpenMPI: `on`

```bash
cmake -DCMAKE_BUILD_TYPE=Release \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DGMX_MPI=${OPEN_MPI_ENABLED} \
        -DGMX_GPU=HIP \
        -DREGRESSIONTEST_DOWNLOAD=OFF \
      ..
```

5. Complete the install with the following make commands
```bash
make -j $(nproc)
make install
```

6. Adding system environment variables
```bash
export ROC_ACTIVE_WAIT_TIMEOUT=0
export AMD_DIRECT_DISPATCH=1
```
Optional, By default GROMACS is installed to: `/usr/local/gromacs`
Adding GROMACS to the system PATH and Library path can be done as follows:
```bash
export PATH=$PATH:/user/local/gromacs/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/user/local/gromacs/lib
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
|Gromacs|LGPL 2.1|[Gromacs](https://www.gromacs.org/)<br /> [Gromacs License](https://github.com/gromacs/gromacs/blob/main/COPYING)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

The GROMACS source code and selected set of binary packages are available here: www.gromacs.org. GROMACS is Free Software, available under the GNU Lesser General Public License (LGPL), version 2.1. You can redistribute it and/or modify it under the terms of the LGPL as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale. AMD, the AMD Arrow logo and combinations thereof are trademarks of Advanced Micro Devices, Inc. Other product names used in this publication are for identification purposes only and may be trademarks of their respective companies.

## Notices and Attribution
© 2021-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
