# Cholla Bare Metal Build Instructions 

## Overview
This document provides instructions on how to do a bare metal install of Cholla in a Linux environment. 

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
|ROCm|5.3.0|latest|
|OpenMPI|4.0.3|5.0.3|
|UCX|1.13.0|1.16.0|
|HDF5|1.12.1|1.14.1|

## Installing Cholla

1. Validate the Cluster/System has all of the above applications, with system path, library, and include environments set correctly. If you are unsure, the [Dockerfile](/cholla/docker/Dockerfile) has examples of all useful configurations listed after the `ENV` commands. 
2. Clone the [Cholla GIT repo](https://github.com/cholla-hydro/cholla.git) into your workspace. 
```bash
git clone -b CAAR --recursive https://github.com/cholla-hydro/cholla.git
```
3. Customize the host file for the Cluster. An example [make.host](/cholla/docker/make.host.cholla-container) file is available. The build will use the host name of the system or environment variable `CHOLLA_MACHINE` for build details. 
    - Save a copy of the [make.host](/cholla/docker/make.host.cholla-container) in `/path/to/cholla/builds` to build and/or run benchmarks. 
    - Rename it appropriately for the cluster/system to be built/run on. 
    - Update `AMDGPU_TARGETS`, `OMPI_ROOT`, `HDF5_ROOT` and `ROCM_PATH` in the make.host file to match your cluster. 
4. Building Cholla
```bash
cd /path/to/cholla
make
```
5. (Optional) Adding Cholla to System Path  
After the build has completed a binary will be created at `cholla/bin/cholla.hydro.[hostname]`. 
This binary can be moved without causing linking issues and placed appropriately for your cluster.
**Be sure to add the Binary to your PATH!**
```bash
PATH=$PATH:/path/to/cholla/bin
```
> Installation Recommendations:
> - Use branch: `CAAR` 
> - Installing 'in place' can allow for ease of use and future updates. 
>   - Example benchmark/workloads located in `cholla/examples` 
>   - Adding clusters make.host.[host-name] file to `cholla/builds` for easy future builds. 

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
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
