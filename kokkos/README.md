# Kokkos

## Description
Kokkos is a C++ library and programming model designed to help with the development of HPC applications.
It provides a framework for writing code that can runs on various hardware platforms, including CPUs, GPUS, and accelerators.
Kokkos allows code to be written that targets complex architectures with multiple memory hierarchies and execution resources. 
Kokkos-Kernels is a utility library affiliated with Kokkos that implements common computational kernels for linear algebra and graph operations. 
The Kokkos-Kernels library also supports ROCm tools libraries such as rocBLAS and rocSPARSE.


## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Building Recipes
[Docker/Singularity Build](/kokkos/docker/)


## Getting started with Kokkos
The build recipe provided here is to provide a clean environment to work with Kokkos and to help facilitate creating a Kokkos-Enabled application. 
In the docker container, the environment has been setup so that the headers and libraries have been included in the environment and are ready to build on top of.  
Popular projects that use Kokkos: [LAMMPS](/lammps/), [Trillnos](https://trilinos.github.io/), [BabelStream](https://github.com/UoB-HPC/BabelStream)

There are many more options that can be added, they are listed on [Kokkos Wiki](https://kokkos.github.io/kokkos-core-wiki/keywords.html). Each project is unique with different requirements, the build provided here is very basic with the tests enabled. With these tests Kokkos can be tuned for any environment.

To run the tests in the provided container instructions, [start up the image](/kokkos/docker/README.md#running-kokkos-container).  
To run Kokkos' suite of tests, use: 
```
cd /kokkos/build
ctest
```
To run the Kokkos-Kernels tests:
```
cd /kokkoskernels/build
ctest
```

For more details on Kokkos and Kokkos-Kernels, see [Kokkos Documentation](https://kokkos.github.io/kokkos-core-wiki/index.html) and [Kokkos-Kernels Documentation](https://github.com/kokkos/kokkos-kernels/wiki).


## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components: 
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|Google Benchmark|Apache v2.0|[Google Benchmark](https://github.com/google/benchmark) <br/> [Google Benchmark License](https://github.com/google/benchmark/blob/main/LICENSE)|
|Kokkos|Apache v2.0|[Kokkos](https://kokkos.org/)<br /> [Kokkos License](https://github.com/kokkos/kokkos/blob/master/LICENSE)|
|Kokkos-Kernels|Apache v2.0|[Kokkos-Kernels](https://kokkos.org/)<br /> [Kokkos-Kernels License](https://github.com/kokkos/kokkos-kernels?tab=License-1-ov-file#readme)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale. AMD, the AMD Arrow logo and combinations thereof are trademarks of Advanced Micro Devices, Inc. Other product names used in this publication are for identification purposes only and may be trademarks of their respective companies.

## Notices and Attribution
© 2021-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.




