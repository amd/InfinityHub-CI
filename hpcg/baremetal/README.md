# rocHPCG Bare Metal Build Instructions

## Overview
This document provides instructions on how to do a bare metal install of rocHPCG in a Linux environment. 

## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver |
| ---- | ---- | ----------------- | ------------ |
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility <br> ROCm v6.x compatibility |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## System Dependencies
|Application|Minimum|Recommended|
|---|---|---|
|Git|Latest|Latest|
|ROCm|5.3.0|5.4.2|
|CMAKE|3.22.2|Latest|
|OpenMPI (Optional)|4.0.3|4.1.5|
|UCX (Optional)|1.13.0|1.14.1|


## Installing rocHPCG
1. Validate the Cluster/System has all of the above applications, with system path, library, and include environments set correctly. If you are unsure, the [Dockerfile](/gromacs/docker/Dockerfile) has examples of all useful configurations listed after the `ENV` commands. 

2. Clone the [rocHPCG](https://github.com/ROCmSoftwarePlatform/rocHPCG.git) into your workspace. The `master` branch is the recommended. 
```
git clone -b master https://github.com/ROCmSoftwarePlatform/rocHPCG.git
```

3. Navigate into the `rocHPCG` directory and runn the following command:
``` 
./install.sh \
      --with-mpi=</path/to/mpi>  \
      --with-rocm=</path/to/rocm> \
      --gpu-aware-mpi=ON \
      --with-openmp=ON \
      --with-memmgmt=ON \
      --with-memdefrag=ON
```
> - Replace `</path/to/ompi>` with the path to mpi implementation to use  
> - Replace `</path/to/rocm>` with the path to rocm installation to use  
> - If unsure of system dependencies are met, providing the `-d` parameter to install any dependencies necessary. 
> - If the `-i` parameter is used, it installs hpcg into rocm, and step 4 can be skipped. 

4. Link binary into correct path. 
This installation will create a binary `rochpcg`, if installed correctly will be:
`/path/to/rocHPCG/build/release/bin`
There is already a `hpcg` binary in `/rocm/bin` remove it 
```
rm -f /path/to/rocm/bin/hcpg
```
after it has been removed, link `rochpcg` in its place. 
```
ln -s /path/to/rocHPCG/build/release/bin/rochpcg /path/to/rocm/bin/rocm/bin/hpcg
```

5. (Optional) Add rocm/bin to System PATH.
If rocm is not already in the system PATH, it along with HPCG can be added with the following command
```bash
export PATH=PATH:/path/to/rocm/bin/
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

