# PETSc Docker Build Instructions
Instructions on how to build a Docker Container with PETSc.


## System Requirements
- Git
- Docker

## Inputs:
Possible `build-arg` for the Docker build command    

- ### IMAGE
    Default: `rocm_gpu:6.4`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).


- ### PETSc_BRANCH
    Default: default: `v3.22.2`  
    Branch/Tag found: [ PETSc repo](https://github.com/petsc/petsc.git).
    >NOTE:  
    >Initial HIP support was added in v3.18.0 with further optimizations included in minor releases. We recommend using v3.19 or newer for performance runs on AMD hardware

## Building PETSc Container:
Download the all files at [PETSc Docker](/petsc/docker/)  

To run the default configuration:
```
docker build -t mycontainer/PETSc -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/PETSc` will be the name of your local container.
>- the `.` at the end of the build line is important! It tells Docker where your build context is located!
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 
>- The `benchmark` directory is required within the build context directory, and the contents will be copied into the container. We have provided three benchmarks, and instructions on how to run them ([see below](#running-PETSc-container)). If you plan on running PETSc against your own data set, it can be copied into the container by placing it in the benchmark directory before building or mounted into the container using dockers mount/volume API. 



To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/PETSc \
    -f /path/to/Dockerfile \
    --build-arg PETSc_BRANCH=v3.18.2 \
    . 
```


## Running PETSc Container
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

To run the [PETSc Benchmarks](/petsc/README.md#running-petsc-benchmark), just replace the `<PETSc Command>` the examples in [Running PETSc Benchmarks](/petsc/README.md#running-petsc-benchmark) section of the PETSc readme. The commands can be run directly in an interactive session as well. 

### Docker  

#### Docker Interactive
To run the container and build the benchmark interactively 
``` 
docker run --rm -it \
    --device /dev/dri \
    --device /dev/kfd \
    --security-opt seccomp=unconfined \
    -w /opt/petsc \
    mycontainer/PETSc  /bin/bash
```

#### Docker Single Command
To run the benchmark using docker with a single command
```
docker run --rm -it \
    --device /dev/dri \
    --device /dev/kfd \
    --security-opt seccomp=unconfined \
    -w  /opt/petsc \
    mycontainer/PETSc  \
    <PETSc Command> 
```

### Singularity  
This section assumes that an up-to-date version of Singularity is installed on your system and properly configured for your system. Please consult with your system administrator or view official Singularity documentation.
To build a Singularity container from your local Docker container, run the following command:
```
singularity build petsc.sif docker-daemon://mycontainer/PETSc
```


#### Singularity Interactive
To launch a Singularity image build into an interactive session
```
singularity shell \
    --no-home \
    --pwd /opt/petsc \
    --writable-tmpfs \
    petsc.sif \
    /bin/bash
```

#### Singularity Single Command
To launch a Singularity image with a single command, useful for batch scrips. 
```
singularity run \
    --no-home \
    --pwd /opt/petsc \
    --writable-tmpfs \
    petsc.sif \
    <PETSc Command>
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
|PETSc|BSD-2 Clause | [PETSc License](https://petsc.org/release/install/license/)|
|Scotch|CeCILL-C|[Scotch Web Page](https://www.labri.fr/perso/pelegrin/scotch/)<br /> [Scotch License](https://gitlab.inria.fr/scotch/scotch/-/blob/master/LICENSE_en.txt)|
|HYPRE|Apache V2.0/MIT|[HYPRE Licenses](https://github.com/hypre-space/hypre#license)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER. 

## Disclaimer  
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.   

## Notices and Attribution  
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.  
Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.  Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.    

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.   


