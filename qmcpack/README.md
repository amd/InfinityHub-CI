# QMCPACK


## Overview
[QMCPACK](https://github.com/QMCPACK/qmcpack) is an open-source production-level many-body ab initio Quantum Monte Carlo code for computing the electronic structure of atoms, molecules, 2D nanomaterials and solids. The solid-state capabilities include metallic systems as well as insulators. QMCPACK is expected to run well on workstations through to the latest generation supercomputers. Besides high performance, particular emphasis is placed on code quality and reproducibility.



## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 


## Building Recipes
[Docker/Singularity Build](/qmcpack/docker/)

## Running QMCPACK Benchmark
There are several [examples](https://github.com/QMCPACK/qmcpack/tree/develop/examples) available within the QMCPACK repo.

This document will show how to run the CORAL-2 benchmark which is provided in this repo.

First untar the CORAL-2 benchmark
```
tar -xf coral_doe_fom.tar.gz
```
Navigate to the benchmark. 
```
cd /path/to/coral_doe_fom 
```
Copy/Link h5 file.  
This benchmark uses Hierarchical Data Format provided in qmc-data /path/to/qmc-data/NiO/NiO-fcc-supertwist111-supershift000-S64.h5 
(Data is pulled from https://anl.app.box.com/s/yxz1ic4kxtdtgpva5hcmlom9ixfl3v3c)
(More information about benchmarks can be found from https://github.com/QMCPACK/qmcpack/tree/develop/tests/performance/NiO)
```
ln -s /path/to/qmc-data/NiO/NiO-fcc-supertwist111-supershift000-S64.h5 .
```
> This has already been done within the example dockerfile provided. 

Execute  
```
/path/to/qmcpack/build/bin/qmcpack NiO-fcc-S64-dmc.xml
```

The FOM can be calculated as follows:
```
target walkers * DMCBatched::RunSteps#Column4 / DMCBatched::RunSteps#Column2
```
These values can be found at the end of the logs of a successful run.

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
|QMCPACK|BDS 3-Clause with additional notes|[QMCPACK](https://github.com/QMCPACK/qmcpack) <br /> [QMCPACK License](https://github.com/QMCPACK/qmcpack/blob/develop/LICENSE)|
|HDF5|BSD-like(CUSTOM)|[HDF5 License](https://github.com/HDFGroup/hdf5/blob/develop/COPYING)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

