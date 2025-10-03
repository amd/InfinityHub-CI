# LAMMPS Container Build Instructions
This document provides instructions on how to build LAMMPS into a Docker container that is portable between environments. 


## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:7.0`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).


- ### LAMMPS_BRANCH
    Default: `patch_27Jun2024`  
    Branch/Tag found: [LAMMPS repo](https://github.com/lammps/lammps)

## Building a Docker container for LAMMPS
Download the [Dockerfile](/lammps/docker/Dockerfile)  

To run the default configuration:
```bash
docker build -t mycontainer/lammps -f /path/to/Dockerfile . 
```
>Notes:
>- `mycontainer/lammps` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```bash
docker build \
    -t mycontainer/lammps \
    -f /path/to/Dockerfile \
    --build-arg LAMMPS_BRANCH=stable_23Jun2022_update3 \
    . 
```

## Running the LAMMPS Container
Both Docker and Singularity can be run interactively or as a single command.
To run the [LAMMPS Benchmarks](/lammps/README.md#running-lammps-benchmarks), just replace the `<LAMMPS Command>` the examples in [Running LAMMPS Benchmarks](/lammps/README.md#running-lammps-benchmarks) section of the LAMMPS readme. The commands can be run directly in an interactive session as well. 


### Docker  

#### Docker Interactive
To run the container interactively, run the following command:
```bash
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/lammps  bash
```
and launch any LAMMPS command from the prompt. 


#### Docker Single Command
```bash
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           mycontainer/lammps  \
           <LAMMPS Command>
```
### Singularity  
To build a Singularity image from your local Docker image, run the following command:
```bash
singularity build lammps.sif  docker-daemon://mycontainer/lammps:latest
```

#### Singularity Interactive
To launch a Singularity image build locally
```bash
singularity shell --no-home --writable-tmpfs --pwd /benchmark lammps.sif
```
#### Singularity Single Command
```bash
singularity exec --no-home --pwd /benchmark lammps.sif <LAMMPS Command>
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
|LAMMPS|GPLv2.0|[LAMMPS](https://www.lammps.org/)<br /> [LAMMPS License](https://docs.lammps.org/Intro_opensource.html)|
|NumPy|BSD 3-clause|[NumPy License](https://github.com/numpy/numpy/blob/main/LICENSE.txt)|
|PANDAS|BSD 3-clause|[PANDAS license](https://github.com/pandas-dev/pandas/blob/main/LICENSE)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Notices and Attribution

The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## License and Attributions

© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
