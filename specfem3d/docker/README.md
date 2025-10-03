# SPECFEM3D Docker Build Instructions 
This document provides instructions on how to build SPECFEM3D into a Docker container that is portable between environments.

## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:7.0`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

- ### SPECFEM3D_BRANCH
    Default: `4.1.1`  
    Branch/Tag found: [SPECFEM3D repo](https://github.com/specfem/specfem3d/)

## Building Container
Download the [Dockerfile](/specfem3d/docker/Dockerfile)

To run the default configuration:
```
docker build -t mycontainer/specfem3d -f /path/to/Dockerfile . 
```
> Notes:  
>- `mycontainer` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.  
```
docker build \
    -t mycontainer/specfem3d \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm_gpu=6.1.1 \
    --build-arg SPECFEM3D_BRANCH=devel
    . 
```

## Running an SPECFEM3D Container
Both Docker and Singularity can be run interactively or as a single command.

To run the [SPECFEM3D Benchmarks](/specfem3d/README.md#running-specfem3d-benchmarks), just replace the `<SPECFEM3D Command>` the examples in [Running SPECFEM3D Benchmarks](/specfem3d/README.md#running-specfem3d-benchmarks) section of the SPECFEM3D readme. The commands can be run directly in an interactive session as well. 

### Docker  

#### Docker Interactive
```
docker run --rm -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -w /benchmark/ \
    mycontainer/specfem3d /bin/bash
```
#### Docker Single Command
```
docker run --rm -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -w /benchmark/benchmarks/tiny/generation/ \
    -v $(pwd):/benchmark/benchmarks/tiny/generation/lattices  
    mycontainer/specfem3d <SPECFEM3D Command>
```

### Singularity  

#### Build Singularity image from Docker
To build a Singularity image from the locally created docker file do the following:
```
singularity build specfem3d.sif docker-daemon://mycontainer/specfem3d:latest
```

#### Singularity Interactive
To launch a Singularity image build locally.
```
singularity shell \
    --no-home \
    --writable-tmpfs \
    --pwd /benchmark/ \
    specfem3d.sif
```

#### Singularity Single Command
To launch a Singularity image build locally.
```
singularity run \
    --no-home \
    --writable-tmpfs \
    --pwd /benchmark/benchmarks/tiny/generation \
    specfem3d.sif <SPECFEM3D Command>
```

## Licensing Information
Your use of this SPECFEM3D application (“Application”) is subject to the terms of the BSD-2 License ([https://opensource.org/licenses/BSD-2-Clause](https://opensource.org/licenses/BSD-2-Clause)) as set forth below. By accessing or using this Application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application. For the avoidance of doubt, this license supersedes any other agreement between AMD and you with respect to your access or use of the Application.

BSD 2 Clause

Copyright © 2023-24, Advanced Micro Devices, Inc. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The Application specifications provided includes the following separate and independent components: 
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|SpecFEM 3d Cartesian |GNU GPl 3 Clause|[SpecFEM 3d Cartesian](https://specfem3d.readthedocs.io/en/latest/01_introduction/)<br />[SpecFEM 3d Cartesian License](https://specfem3d.readthedocs.io/en/latest/D_license/#license)|
|BLIS|BSD 3-Clause|[BLIS License](https://github.com/amd/blis/blob/master/LICENSE)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.   

## Notices and Attribution
© 2023-24 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.  

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.  Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.    

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
