# AMD Base ROCm Container with Conda

## Overview
This container recipe uses the "base-gpu-mpi-rocm-docker" as the base and adds Conda.
The container can be used as a base for applications that require conda applications.

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Docker Container Build
These instructions use Docker to create an HPC Application Container.  
If you are not familiar with creating Docker builds, please see the available [Docker manuals and references](https://docs.docker.com/).

### Application
Many Applications require components or applications that are not available using `apt-get`. These may be installed, per the applications installation instructions, at the section of the Docker file with the comment `# Install Additional Apps Below`. Add any binary, libraries, or include file paths to the appropriate environment variables. After adding any additional applications add the desired application at the bottom of that section. 

There are a few ways to get additional applications into the container. 
- Conda: use Conda to wide range of packages, including libraries for scientific computing, data analysis, machine learning, and various programming languages, all while managing their dependencies and environments.
    - To install `conda` packages, simply add `conda install <package name>` 
- CURL/wget: download the binary/source and compile, using docker RUN command
- Source Control: Git is included; To uses a different SCM, add the desired SCM using `apt-get` as above. Clone your repo and build your application, using docker RUN command 
- The Docker COPY command: command to copy in files directory from the users local system.

## Inputs
Possible `build-arg` for the Docker build command

- ### IMAGE
    Default: `rocm_gpu:6.4`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

## Building Container
Download the [Dockerfile](/conda-rocm-environment/Dockerfile)  

To run the default configuration:
```
docker build -t conda_rocm_gpu:6.4 -f /path/to/Dockerfile . 
```
> Notes:  
>- `conda_rocm_gpu:6.4` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required.
>
>- To run a custom configuration, include one or more customized build-arg parameters.   
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.  

```
docker build \
    -t conda_rocm_gpu:6.4 \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=<custom_image>
    .
```

## Running an Application Container:
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

### Docker  
To run the container interactively, run the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it conda_rocm_gpu:6.4 bash
```
> ** Notes **
> User running container user must have permissions to `/dev/kfd` and `/dev/dri`. This can be achieved by being a member of `video` and/or `render` group.  
> Additional Parameters
> - `-v [system-directory]/[container-directory]` will mount a directory into the container at run time.
> - `-w [container-directory]` will designate what directory within a container to start in.

### Singularity  
Singularity, like Docker, can be used for running HPC containers.  
To create a Singularity container from your local Docker container, run the following command:
```
singularity build conda_rocm_gpu.sif  docker-daemon://conda_rocm_gpu:6.4
```

Singularity can be used similar to Docker to launch interactive and non-interactive containers, as shown in the following example of launching a interactive run
```
singularity shell --writable-tmpfs conda_rocm_gpu.sif
```
> - `--writable-tmpfs` allows for the file system to be writable, many benchmarks/workloads require this.  
> - `--no-home` will *not* mount the users home directory into the container at run time. 
> - `--bind [system-directory]/[container-directory]` will mount a directory into the container  at run time. 
> - `--pwd [container-directory]` will designate what directory within a container to start in. 

*For more details on Singularity please see their [User Guide](https://docs.sylabs.io/guides/3.7/user-guide/)*

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|Conda|BSD 3-Clause|[Conda License](https://docs.conda.io/en/latest/license.html)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
