# PeleC Docker Build Instructions 
This document provides instructions on how to build PeleC into a Docker container that is portable between environments.


## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:6.4`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

- ### PELEC_BRANCH
    Default: `development`  
    Branch/Tag found: [PeleC repo](https://github.com/AMReX-Combustion/pelec/)


## Building Container
Download the [Dockerfile](/pelec/docker/Dockerfile)

To run the default configuration:
```
docker build -t mycontainer/pelec -f /path/to/Dockerfile . 
```
> Notes:  
>- `mycontainer` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.  

```
docker build \
    -t mycontainer/pelec \
    -f /path/to/Dockerfile \
    --build-arg PELEC_BRANCH=main
    . 
```

## Running an PeleC Container
Both Docker and Singularity can be run interactively or as a single command.

To run the [PeleC Benchmarks](/pelec/README.md#running-pelec-benchmarks), just replace the `<PeleC Command>` the examples in [Running PeleC Benchmarks](/pelec/README.md#running-pelec-benchmarks) section of the PeleC readme. The commands can be run directly in an interactive session as well. 

### Docker  
If you want access to the HDF5 files generated during the run, please add `-v $(pwd):/benchmark` before `mycontainer/pelec` in the following commands. 

#### Docker Interactive
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined mycontainer/pelec /bin/bash
```
#### Docker Single Command
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined mycontainer/pelec <PeleC Command>
```

### Singularity  
If you want access to the HDF5 files generated during the run, please add `--bind $(pwd):/benchmark` before `pelec.sif` in the following run commands.
#### Build Singularity image from Docker
To build a Singularity image from the locally created docker file do the following:
```
singularity build pelec.sif docker-daemon://mycontainer/pelec:latest
```

#### Singularity Interactive
To launch the Singularity image in interactive mode:
```
singularity shell --no-home --writable-tmpfs --pwd /benchmark pelec.sif
```

#### Singularity Single Command
To launch the Singularity image and run the benchmark specified by `<PeleC Command>`:
```
singularity run --no-home --writable-tmpfs --pwd /benchmark pelec.sif <PeleC Command>
```



## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any sub-component in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|PeleC|PeleC Copyright Custom|[Pele Suite](https://amrex-combustion.github.io/)<br />[PeleC License](https://github.com/AMReX-Combustion/PeleC?tab=License-1-ov-file)|
|PelePhysics|PelePhysics Copyright Custom|[Pele Suite](https://amrex-combustion.github.io/)<br />[PelePhysics License](https://github.com/AMReX-Combustion/PelePhysics?tab=License-1-ov-file)|
|AMReX|AMReX Copyright Custom|[AMReX](https://github.com/AMReX-Codes)<br />[AMReX License](https://github.com/AMReX-Codes/amrex?tab=License-1-ov-file)|
|SUNDIALS|BSD 3-Clause| [SUNDIALS](https://github.com/LLNL/sundials/)<br />[SUNDIALS License](https://github.com/LLNL/sundials?tab=License-1-ov-file)|



Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
