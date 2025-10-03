# Trilinos Docker Build Instructions 
This document provides instructions on how to build Trilinos into a Docker container that is portable between environments.

## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:7.0`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

- ### TRILINOS_BRANCH
    Default: `develop`  
    Branch/Tag found: [Trilinos repo](https://github.com/trilinos/trilinos.git)

- ### ZLIB_BRANCH
    Default: `v1.2.13`  
    Branch/Tag found: [zlib repo](https://github.com/madler/zlib.git)

- ### HDF5_BRANCH
    Default: `hdf5-1_14_3`  
    Branch/Tag found: [HDF5 repo](https://github.com/HDFGroup/hdf5.git)

- ### PNETCDF_BRANCH
    Default: `checkpoint.1.12.3`  
    Branch/Tag found: [PNetCDF repo](https://github.com/Parallel-NetCDF/pnetcdf.git)

- ### NETCDF_BRANCH
    Default: `v4.9.0`  
    Branch/Tag found: [netcdf-c repo](https://github.com/Unidata/netcdf-c.git )

- ### MATIO_BRANCH
    Default: `v1.5.23`  
    Branch/Tag found: [Matio repo](https://github.com/tbeu/matio.git)

- ### BOOST_BRANCH
    Default: `boost-1.80.0`  
    Branch/Tag found: [Boost repo](https://github.com/boostorg/boost.git)

- ### NUM_BUILD_THREADS
    Default: `32`  
    Description: Number of threads to build each app with.
    


## Building Container
Download the [Dockerfile](/trilinos/docker/Dockerfile) 

To run the default configuration:
```
docker build -t mycontainer/trilinos -f /path/to/Dockerfile . 
```
> Notes:  
>- `mycontainer` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.  

```
docker build \
    -t mycontainer/trilinos \
    -f /path/to/Dockerfile \
    --build-arg TRILINOS_BRANCH=trilinos-release-15-0-0 \
    --build-arg HDF5_BRANCH=develop
    . 
```

## Running an Trilinos Container
Both Docker and Singularity can be run interactively or as a single command.

To run the [Trilinos Benchmarks](/trilinos/README.md#running-trilinos-benchmarks), just replace the `<Trilinos Command>` the examples in [Running Trilinos Benchmarks](/trilinos/README.md#running-trilinos-benchmarks) section of the Trilinos readme. The commands can be run directly in an interactive session as well. 

### Docker  
If you want access to the HDF5 files generated during the run, please add `-v $(pwd):/benchmark` before `mycontainer/trilinos` in the following commands. 

#### Docker Interactive
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined mycontainer/trilinos /bin/bash
```
#### Docker Single Command
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined mycontainer/trilinos <Trilinos Command>
```

### Singularity  
If you want access to the HDF5 files generated during the run, please add `--bind $(pwd):/benchmark` before `trilinos.sif` in the following run commands.
#### Build Singularity image from Docker
To build a Singularity image from the locally created docker file do the following:
```
singularity build trilinos.sif docker-daemon://mycontainer/trilinos:latest
```

#### Singularity Interactive
To launch a Singularity image build locally.
```
singularity shell --no-home --writable-tmpfs --pwd /benchmark trilinos.sif
```

#### Singularity Single Command
To launch a Singularity image build locally.
```
singularity run --no-home --writable-tmpfs --pwd /benchmark trilinos.sif <Trilinos Command>
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
|Trilinos|BSD 3-Clause, LGPL|[Trilinos](https://github.com/trilinos/Trilinos)<br >[Trilinos License](https://trilinos.github.io/license.html)|
|HDF5|BSD-like(CUSTOM)|[HDF5 License](https://github.com/HDFGroup/hdf5/blob/develop/COPYING)|
|ZLIB|MIT|[ZLIB License](https://github.com/madler/zlib?tab=License-1-ov-file#readme)|
|PNetCDF|CUSTOM|[PNetCDF License](https://github.com/Parallel-NetCDF/PnetCDF/blob/master/COPYRIGHT)|
|NetCDF-c|BSD-3-Clause|[NEtCDF-c License](https://github.com/Unidata/netcdf-c?tab=BSD-3-Clause-1-ov-file#readme)|
|Matio|BSD-2-Clause|[Matio License](https://github.com/tbeu/matio?tab=BSD-2-Clause-1-ov-file#readme)|
|Boost|BSL-1 License|[Boost License](https://github.com/boostorg/boost?tab=BSL-1.0-1-ov-file#readme)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.
