# nekRS


## Overview
[nekRS](https://github.com/Nek5000/nekRS/tree/master?tab=readme-ov-file) nekRS is a computational fluid dynamics code developed at ANL, UIUC, and PSU. nekRS aims to leverage the present trend in GPU-based HPC systems to perform CFD on GPU-accelerated systems. By using the OCCA library’s unified API, nekRS can run on CPUs and on GPU-accelerated CPUs that support CUDA, HIP, or OpenCL.


## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 


## Building Recipes
[Docker/Singularity Build](/nekRS/docker/)

## Running nekRS Benchmark
There are several [examples](https://github.com/Nek5000/nekRS/tree/master/examples) available within the nekRS repo.

This document will show how to run the turbPipePeriodic benchmark which is provided in this repo.

First navigate the turbPipePeriodic directory
```
cd path/to/nekrs/examples/turbPipePeriodic
```
Set Environment Variable NEKRS_HOME
```
export NEKRS_HOME=/path/to/nekrs
```
Run the turbPipe benchmark \
 **_NOTE:_** -np option provides number of GPUs. This is a 2 GPU example
```
mpirun -np 2 nekrs --setup turbPipe.par
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
|nekRS|BSD 3-Clause with additional notes|[nekRS](https://github.com/Nek5000/nekRS/tree/master) <br /> [nekRS License](https://github.com/Nek5000/nekRS/blob/master/LICENSE)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
