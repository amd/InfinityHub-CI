# PIconGPU Docker Build Instructions
Instructions on how to build a Docker Container with PIconGPU.


## System Requirements
- Git
- Docker

## Inputs:
Possible `build-arg` for the Docker build command    

- ### IMAGE
    Default: `rocm_gpu:7.0`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).


- ### PICONGPU_BRANCH
    Default: default: `dev`  
    Branch/Tag found: [ PIconGPU repo](https://github.com/ComputationalRadiationPhysics/picongpu).
    >NOTE:  
    >master branch branch has different tests, benchmarks, examples. The test build into this container is not available the master branch at this time.

- ### HDF5_BRANCH
    Default: `hdf5-1_14_1`  
    Branch/Tag found: [HDF5 repo](https://github.com/HDFGroup/hdf5.git)

- ### ALPAKA_BRANCH
    Default:  `develop`
    Branch/Tag found: [Alpaka repo](https://github.com/alpaka-group/alpaka.git)


## Building PIconGPU Container:
To run the default configuration:
```
docker build -t mycontainer/picongpu -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/picongpu` will be the name of your local container.
>- the `.` at the end of the build line is important! It tells Docker where your build context is located!
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 



To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance. 
```
docker build \
    -t mycontainer/PIconGPU \
    -f /path/to/Dockerfile \
    --build-arg PICONGPU_BRANCH=dev \
    . 
```


## Running PIconGPU Container
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation. 
PNGwriter and HDF-5 have been provided inside this container to help generate visual outputs. To access outside of the container mount an output directory the container using dockers/singularity mount/volume API.

To run the [PIconGPU Benchmarks](/picongpu/README.md#running-picongpu-benchmark), just replace the `<PIconGPU Command>` the examples in [Running PIconGPU Benchmarks](/picongpu/README.md#running-picongpu-benchmark) section of the PIconGPU readme. The commands can be run directly in an interactive session as well. 

### Docker  

#### Docker Interactive
To run the container and build the benchmark interactively 
``` 
docker run --rm -it \
    --device /dev/dri \
    --device /dev/kfd \
    --security-opt seccomp=unconfined \
    -w /opt/picon-examples/khi_fom \
    mycontainer/picongpu  /bin/bash
```

#### Docker Single Command
To run the benchmark using docker with a single command
```
docker run --rm -it \
    --device /dev/dri \
    --device /dev/kfd \
    --security-opt seccomp=unconfined \
    -w  /opt/picon-examples/khi_fom \
    mycontainer/picongpu  \
    <PIconGPU Command> 
```

### Singularity  
This section assumes that an up-to-date version of Singularity is installed on your system and properly configured for your system. Please consult with your system administrator or view official Singularity documentation.
To build a Singularity container from your local Docker container, run the following command:
```
singularity build picongpu.sif docker-daemon://mycontainer/picongpu
```


#### Singularity Interactive
To launch a Singularity image build into an interactive session
```
singularity shell \
    --no-home \
    --pwd /opt/picon-examples/khi_fom \
    --writable-tmpfs \
    picongpu.sif 
```

#### Singularity Single Command
To launch a Singularity image with a single command, useful for batch scrips. 
```
singularity run \
    --no-home \
    --pwd /opt/picon-examples/khi_fom \
    --writable-tmpfs \
    picongpu.sif \
    <PIconGPU Command>
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
|PIconGPU|GPLv3+ license | [PIconGPU](https://picongpu.readthedocs.io/en/latest/) <br/> [PIconGPU License](https://github.com/ComputationalRadiationPhysics/picongpu/blob/master/LICENSE.md)|
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
