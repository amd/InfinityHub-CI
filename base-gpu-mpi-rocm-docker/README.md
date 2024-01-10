# AMD Base Container for GPU-Aware MPI with ROCm using OpenMPI/UCX Applications

## Overview
This container recipe is a 'boiler-plate' to building a container using ROCm and OpenMPI/UXC that is GPU-Aware MPI.  
This recipe does not support OpenMP-offloading as is.  
Please set add the following before installing OpenMPI to allow for OpenMP support:

```
env CC=$ROCM_PATH/bin/amdclang \
    CXX=$ROCM_PATH/bin/amdclang++ \
    FC=$ROCM_PATH/bin/amdflang
```

This container builds for the GPU attached to the system it is built on. 
If there is no GPU on the system/node it is build on please update `$(/opt/rocm/bin/offload-arch)` in the following command with the GPU architecture for the cluster. 
```
echo "$(/opt/rocm/bin/offload-arch)" > /opt/rocm/bin/target.lst
```
- MI100 - gfx908
- MI200 - gfx90a
- MI300A - gfx942

## Single-Node Server Requirements

| CPUs | APUs/GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) |AMD Instinct MI300A APU(s) <br> AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility <br> ROCm v6.x compatibility|[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Docker Container Build
These instructions use Docker to create an HPC Application Container.  
If you are not familiar with creating Docker builds, please see the available [Docker manuals and references](https://docs.docker.com/).

### Build System Requirements
- Git
- Docker

### Updating the Dockerfile

#### Apt
The default container does not have every component of ROCm or Ubuntu installed, and additional components may need to be installed depending on your application. If you use the Docker container tag that ends in `*-complete` it will have a more complete ROCm environment, see the [Inputs](#inputs) section for more details. These components can easily be installed using a simple `apt-get install ...` command.
List of available ROCm libraries that can be installed with apt-get: 
`hipblas, hipcub, hipfft, hipsolver, hipsparse, miopen, rccl, rocalution, rocblas, rocfft, rocprim, rocrand, rocsolver, rocsparse, roctracer, rocthrust`

#### HPC Application
Many HPC Applications require components or applications that are not available using `apt-get`. These may be installed, per the applications installation instructions, at the section of the Docker file with the comment `# Install Additional Apps Below`. Add any binary, libraries, or include file paths to the appropriate environment variables similarly to the ROCm, UCX, and OpenMPI examples. After adding any additional applications add the desired HPC Application at the bottom of this section. 

There are a few ways to get additional applications into the container. 
- CURL/wget: download the binary/source and compile, using docker RUN command
- Source Control: Git is included; To uses a different SCM, add the desired SCM using `apt-get` as above. Clone your repo and build your application, using docker RUN command 
- The Docker COPY command: command to copy in files directory from the users local system.  

Please consult the [Docker documentation](https://docs.docker.com/engine/reference/builder) for details.


### Inputs
Possible `build-arg` for the Docker build command  

- #### IMAGE
    Default: `rocm/dev-ubuntu-22.04:6.0-complete`  
    Docker Tags found: 
    - [ROCm Ubuntu 22.04](https://hub.docker.com/r/rocm/dev-ubuntu-22.04)
    - [ROCm Ubuntu 20.04](https://hub.docker.com/r/rocm/dev-ubuntu-20.04)
    > ***Note:***  
    > The `*-complete` version has all the components required for building and installation.  

- #### UCX_BRANCH
    Default: `v1.14.1`  
    Branch/Tag found: [UXC repo](https://github.com/openucx/ucx)

- #### OMPI_BRANCH
    Default: `v4.1.5`  
    Branch/Tag found: [OpenMPI repo](https://github.com/open-mpi/ompi)

- #### APT_GET_APPS
    Default:  `[BLANK]`  
    This allows a user to add additional applications and libraries through the apt-get interface in Ubuntu. Using a space separate list `git vim nano` 


### Building Container
Download the [Dockerfile](/base-gpu-mpi-rocm-docker/Dockerfile)  

To run the default configuration:
```
docker build -t mycontainer -f /path/to/Dockerfile . 
```
> Notes:  
>- `mycontainer` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context, if you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.  

```
docker build \
    -t mycontainer \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm/dev-ubuntu-20.04:5.5-complete \
    --build-arg UCX_BRANCH=master \
    --build-arg OMPI_BRANCH=main \
    --build-arg APT_GET_APPS="vim nano git"
    . 
```

## Running an HPC Container:
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

### Docker
To run the container interactively, run the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it mycontainer bash
```

### Singularity 
Singularity, like Docker, can be used for running HPC containers.  
To create a Singularity container from your local Docker container, run the following command:
```
singularity build mycontainer.sif  docker-daemon://mycontainer:latest
```

Singularity can be used similar to Docker to launch interactive and non-interactive containers, as shown in the following example of launching a interactive run
```
singularity shell mycontainer.sif
```
*For more details on Singularity please see their [User Guide](https://docs.sylabs.io/guides/3.7/user-guide/)*


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

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
