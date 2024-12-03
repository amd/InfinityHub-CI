# PIConGPU

## Overview
The particle-in-cell (PIC) algorithm is a central tool in plasma physics. It describes the dynamics of a plasma by computing the motion of electrons and ions in the plasma based on the Vlasov-Maxwell system of equations.
A description of the particle-in-cell algorithm is available in the [PIConGPU documentation](https://picongpu.readthedocs.io/en/latest/models/pic.html).
The [PIConGPU homepage](http://picongpu.hzdr.de/) also gives a high-level description of the innovations of this code.

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Building Recipes
[Docker/Singularity Build](/picongpu/docker/)

## Running PIConGPU Benchmark
PIConGPU has many [benchmarks](https://github.com/ComputationalRadiationPhysics/picongpu/tree/dev/share/picongpu/benchmarks), [examples](https://github.com/ComputationalRadiationPhysics/picongpu/tree/dev/share/picongpu/examples), and [tests](https://github.com/ComputationalRadiationPhysics/picongpu/tree/dev/share/picongpu/tests).
Building each one is straight forward, see the [PIConGPU Dockerfile](/picongpu/docker/Dockerfile) for how this is done.  
The example here are from the Docker Build, KHI Growth Rate. 
>NOTE: After building any of the examples run `bin/picongpu --help` to get any additional parameters for the given example 

### Run KHI Growth Rate
From the directory where KHI has been build:

#### 1 GPU
```
mpirun -n 1 ./bin/picongpu -d 1 1 1 -g 128 128 128 --periodic 1 1 1 -s 1500 --fields_energy.period 20
```




## Licensing Information 
Your use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application. 

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|PIConGPU|GPLv3+ license | [PIConGPU](http://picongpu.hzdr.de/) <br/> [PIConGPU License](https://github.com/ComputationalRadiationPhysics/picongpu/blob/master/LICENSE.md)|
|HDF5|BSD-like(CUSTOM)|[HDF5 License](https://github.com/HDFGroup/hdf5/blob/develop/COPYING)|
|PNGwriter|GPLv2+|[PNGwriter License](https://github.com/pngwriter/pngwriter/)|
|Alpaka|MPL-2.0|[Alpaka Repo](https://github.com/alpaka-group/alpaka)<br/>[Alpaka License](https://github.com/alpaka-group/alpaka?tab=MPL-2.0-1-ov-file#readme)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER. 

## Disclaimer  
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.   

## Notices and Attribution  
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.  
Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.  Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.    

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.   
