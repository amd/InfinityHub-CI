# NEKO


## Overview
[Neko](https://github.com/ExtremeFLOW/neko) is a portable framework, written using modern Fortran, for high-order spectral element flow simulations. Using an object-oriented design Neko allows for multi-tier abstraction for solver stacks and allows Neko to be build against various typos of hardware backends. Neko uses [Nek5000](https://github.com/Nek5000/Nek5000) from UCHcago/ANL for the spectral element code, also uses it as a base for naming conventions, code structure and numerical methods. 



## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Building Recipes
[Docker/Singularity Build](/neko/docker/)

## Running Neko Benchmark
There are several [examples](https://github.com/ExtremeFLOW/neko/tree/develop/examples) and [benchmarks](https://github.com/ExtremeFLOW/neko/tree/develop/bench) available within the Neko repo.  

This document will show how to run the provided tgv32 benchmark.

First Navigate to the benchmark. 
```
cd /path/to/neko/bench/tgv32
```
Copy/Link mesh.  
This benchmark uses the a mesh provided in the example /path/to/neko/examples/tgv/32768.nmsh 
```
ln -s /path/to/neko/examples/tgv/32768.nmsh /path/to/neko/bench/tgv32/32768.nmsh
```
> This has already been done within the example dockerfile provided. 

Make and Execute  
Replace the # with the number of gpus to use. 
```
makeneko tgv.f90
mpirun -np # ./neko tgv.case
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
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/release/licensing.html)|
|NEKO|BDS 3-Clause with additional notes|[NEKO](https://github.com/ExtremeFLOW/neko) <br /> [NEKO License](https://github.com/ExtremeFLOW/neko/blob/develop/COPYING)|
|JSON Fortran|BDS 3-Clause/MIT|[JSON Fortran]( https://github.com/jacobwilliams/json-fortran.git) <br /> [JSON Fortran License](https://github.com/jacobwilliams/json-fortran/blob/master/LICENSE)|
|GSLIB|BDS 3-Clause with additional notes|[GSLIB](https://github.com/Nek5000/gslib) <br /> [GSLIB License](https://github.com/Nek5000/gslib/blob/master/LICENSE)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
