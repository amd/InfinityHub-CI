# Kokkos Docker Build
Instructions on how to build a Docker Container with Kokkos.  
This Kokkos Container is a platform for building HPC applications using Kokkos and HIP. 


## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:7.0`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

- ### KOKKOS_BRANCH
    Default: `4.2.01`  
    Branch/Tag found: [Kokkos](https://github.com/kokkos/kokkos.git).

- ### ENABLE_OPENMP
    Default: `OFF`  
    Options: `OFF` or `ON`
    If this option is set to off, UCX and Open MPI will not be installed, and the following two options will not be used.

## Building Kokkos Container
Download the [Dockerfile](/kokkos/docker/Dockerfile)  

To run the default configuration:
```
docker build -t mycontainer/kokkos -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/kokkos` is an example container name. 
>- the `.` at the end of the build line is important! It tells Docker where your build context is located!
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required.

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/kokkos \
    -f /path/to/Dockerfile \
    --build-arg KOKKOS_BRANCH=3.7.02 \
    --build-arg ENABLE_OPENMP=ON
    . 
```

## Running Kokkos Container
This provides a clean environment to modify, build, and test any application that can utilized Kokkos or adding Kokkos to an existing project.

> Mount the project into the container  
> Directories/files mounted into the container will persist locally no work is lost.  
> To learn more about mounting directories and files into your container visit [Docker Docs](https://docs.docker.com/storage/volumes/) and [Singularity Docs](https://docs.sylabs.io/guides/3.0/user-guide/bind_paths_and_mounts.html)


### Docker  

#### Docker Interactive
```
docker run --rm -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -v /path/to/my/project:/mnt \
    mycontainer/kokkos \
    /bin/bash
```

### Singularity  

#### Build Singularity image from Docker
To build a Singularity image from the locally created docker file do the following:
```
singularity build kokkos.sif docker-daemon://mycontainer/kokkos:latest
```

#### Singularity Interactive
To launch a Singularity image build locally.
```
singularity shell --no-home \
    --writable-tmpfs \
    --bind /path/to/my/project:/mnt \
    kokkos.sif
```


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
