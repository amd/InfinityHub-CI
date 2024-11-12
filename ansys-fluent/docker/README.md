# Ansys Fluent Base Container

## Overview
This container recipe is a 'boiler-plate' for those with a license for Ansys Fluent. 
A user must have licenses and binaries to be able to use Ansys Fluent within the container. 

## Ansys Fluent
[Ansys Fluent](https://www.ansys.com/products/fluids/ansys-fluent/) is an advanced computational fluid dynamics (CFD) software used for simulating and analyzing fluid flow, heat transfer, and related phenomena in complex systems. It offers a range of powerful features for detailed and accurate modeling of various physical processes, including turbulence, chemical reactions, and multiphase flows. 


## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Docker Container Build
These instructions use Docker to create a container for Ansys Fluent.
This container assumes that you have a license for Ansys Fluent and a tar with the Fluent application provided by Ansys.
These files are expected to be in a directory named `sources` in the docker build context.  
This example, is using a tar with the name `fluent.24.2.lnamd64.tgz`.

If you are not familiar with creating Docker builds, please see the available [Docker manuals and references](https://docs.docker.com/).

## Build System Requirements
- Git
- Docker

## Updating the Dockerfile

### Input values
Within the dockerfile the default value for the `FLUENT_TAR` and `FLUENT_VERSION` can be hard coded before building or input at build time.  
[Build Details](#building-container) can be found below.  

### Ansys License
There are 2 License methods for Ansys Fluent. 
At build time, the `ANSYSLMD_LICENSE_FILE` `build-arg` can be provided or update the [Temporary License section](/ansys-fluent/Dockerfile#L62) by uncommenting out the section and make sure the `ansyslmd.ini` is along side the tar in the `sources` directory.



## Inputs
Possible `build-arg` for the Docker build command  
- ### IMAGE
    Default: `rocm_gpu:6.2.4`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).  
- ### FLUENT_TAR
    Default: `fluent.24.2.lnamd64.tgz`
    > ** Note ** 
    > This should reflect the tar file provided by Ansys. This file must be in the folder `sources` and and this folder must be referenced at build time.

- ### FLUENT_VERSION
    Default: `242`  
    > ** Note ** 
    > This is the numeric version of the Fluent version number. Eg: The example is 24.2, so use 242, as that is the reference in the Fluent tar. 

- ### ANSYSLMD_LICENSE_FILE
    > **MANDATORY!**  
    > If not using the Temporary License, This must be provided. This is the reference to the Ansys License Server/License required to run Ansys Fluent. 


## Building Container
Download the [Dockerfile](/ansys-fluent/Dockerfile)  

To run the default configuration:
```
docker build -t ansys/fluent:latest --build-arg ANSYSLMD_LICENSE_FILE=1234 -f /path/to/Dockerfile . 
```
> Notes:  
>- `ansys/fluent:latest` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located, the Ansys Fluent files should be relative to this path. 
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized `build-arg` parameters.   
*DISCLAIMER:* This Docker build has only been validated using the default values. Alterations may lead to failed builds if instructions are not followed.

```
docker build \
    -t fluent:latest \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm_gpu:6.1.1 \
    --build-arg FLUENT_TAR=fluent.23.2.lnamd64.tgz \
    --build-arg FLUENT_VERSION=232 \
    --build-arg ANSYSLMD_LICENSE_FILE=1055@127.0.0.1 \
    . 
```

## Running an Application Container:
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

### Docker  
To run the container interactively, run the following command:
```
docker run -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt \
    seccomp=unconfined \
    -v /PATH/TO/FLUENT_TEST_FILES/:/benchmark \
    fluent:latest bash
```

> ** Notes **
> User running container user must have permissions to `/dev/kfd` and `/dev/dri`. This can be achieved by being a member of `video` and/or `render` group.  
> Additional Parameters
> - `-v [system-directory]:[container-directory]` will mount a directory into the container at run time.
> - `-w [container-directory]` will designate what directory within a container to start in. 
> - This container is build with `OpenMPI`, to use `Cray MPICH`, it will need to be  mount in over the OpenMPI installation. 
> `-v [/absolute/path/to/mpich]/:/opt/ompi/`  
> Include any/all Cray environment variables necessary using `-e` for each variable  
> `-e MPICH_GPU_SUPPORT_ENABLED=1`

### Singularity  
Singularity, like Docker, can be used for running HPC containers.  
To create a Singularity container from your local Docker container, run the following command:
```
singularity build fluent.sif  docker-daemon://fluent:latest
```

Singularity can be used similar to Docker to launch interactive and non-interactive containers, as shown in the following example of launching a interactive run
```
singularity shell --writable-tmpfs fluent.sif
```
> - `--writable-tmpfs` allows for the file system to be writable, many benchmarks/workloads require this.  
> - `--no-home` will *not* mount the users home directory into the container at run time. 
> - `--bind [system-directory]:[container-directory]` will mount a directory into the container  at run time. 
> - `--pwd [container-directory]` will designate what directory within a container to start in. 
> - This container is build with `OpenMPI`, to use `Cray MPICH`, it will need to be mount in over the OpenMPI installation. 
> `-bind [/absolute/path/to/mpich]/:/opt/ompi/`  
> Include any/all Cray environment variables necessary  using `--env` for each variable  
> `--env MPICH_GPU_SUPPORT_ENABLED=1`



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
|OpenUCC|BSD 3-Clause|[OpenUCC License](https://github.com/openucx/ucc?tab=BSD-3-Clause-1-ov-file#readme)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/release/licensing.html)|
|Ansys Fluent|Custom|[Ansys Fluent](https://www.ansys.com/products/fluids/ansys-fluent)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
