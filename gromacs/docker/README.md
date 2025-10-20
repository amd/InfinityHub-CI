# AMD's Implementation of GROMACS with HIP Docker Build
Instructions on how to build a Docker Container with AMD's implementation of GROMACS.


## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:7.0`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

- ### GROMACS_BRANCH
    Default: `4947-hip-feature-enablement`  
    Branch/Tag found: [AMD's implementation of GROMACS with HIP in upstream repository](https://gitlab.com/gromacs/gromacs).

- ### MPI_ENABLED
    Default: `off`  
    Options: `off` or `on`  

## Building AMD's implementation of GROMACS with HIP Container
Download the [Dockerfile](/gromacs/docker/Dockerfile)  
Download the [benchmark files](/gromacs/docker/benchmark/) 

To run the default configuration:
```
docker build -t mycontainer/gromacs-hip -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/gromacs-hip` is an example container name. 
>- the `.` at the end of the build line is important! It tells Docker where your build context is located!
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 
>- The `benchmark` directory is required within the build context directory, and the contents will be copied into the container. We have provided three benchmarks, and instructions on how to run them ([see below](#running-amd-implementation-of-gromacs-with-hip-container)). If you plan on running AMD's implementation of GROMACS with HIP against your own data set, it can be copied into the container by placing it in the benchmark directory before building or mounted into the container using dockers mount/volume API. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/gromacs-hip \
    -f /path/to/Dockerfile \
    --build-arg GROMACS_BRANCH=4947-hip-feature-enablement \
    --build-arg MPI_ENABLED=on
    . 
```

## Running AMD implementation of GROMACS with HIP Container
Both Docker and Singularity can be run interactively or as a single command.
To run the [GROMACS Benchmarks](/gromacs/README.md#running-gromacs-benchmarks), just replace the `<GROMACS Command>` the examples in [Running GROMACS Benchmarks](/gromacs/README.md#running-gromacs-benchmarks) section of the GROMACS readme. The commands can be run directly in an interactive session as well. 

### Docker  

#### Docker Interactive
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined mycontainer/gromacs-hip /bin/bash
```
### Docker Non-Interactive
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined mycontainer/gromacs-hip <GROMACS Command>
```

### Singularity  

#### Build Singularity image from Docker
To build a Singularity image from the locally created docker file do the following:
```
singularity build gromacs.sif docker-daemon://mycontainer/gromacs-hip:latest
```

#### Singularity Interactive
To launch a Singularity image build locally.
```
singularity shell --no-home --writable-tmpfs --pwd /benchmark gromacs.sif
```

#### Singularity Single Command
To launch a Singularity image build locally.
```
singularity run --no-home --writable-tmpfs --pwd /benchmark gromacs.sif <GROMACS Command>
`

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
|Gromacs|LGPL 2.1|[Gromacs](https://www.gromacs.org/)<br /> [Gromacs License](https://github.com/gromacs/gromacs/blob/main/COPYING)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

The GROMACS source code and selected set of binary packages are available here: www.gromacs.org. GROMACS is Free Software, available under the GNU Lesser General Public License (LGPL), version 2.1. You can redistribute it and/or modify it under the terms of the LGPL as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale. AMD, the AMD Arrow logo and combinations thereof are trademarks of Advanced Micro Devices, Inc. Other product names used in this publication are for identification purposes only and may be trademarks of their respective companies.

## Notices and Attribution
© 2021-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
