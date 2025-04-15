# OpenFOAM with PETSc solver Docker Build
Instructions on how to build a Docker Container with OpenFOAM using the PETSc solver.

## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:6.4`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/).
    
- ### OPENFOAM_VERSION
    Default: `v2406`  
    Branch/Tag found: [OpenFOAM repo](https://develop.openfoam.com/Development/openfoam)

- ### SCOTCH_VER
    Default: `v7.0.6`  
    Branch/Tag found: [Scotch repo](https://gitlab.inria.fr/scotch/scotch.git)

- ### PETSC_VER
    Default: `v3.22.2`  
    Branch/Tag found: [PETSc repo](https://gitlab.com/petsc/petsc)  
    >NOTE:  
    >Initial HIP support was added in v3.18.0 with further optimizations included in minor releases. We recommend using v3.19 or newer for performance runs on AMD hardware

## Building OpenFOAM Container
- Download the everything in [OpenFOAM/docker](/openfoam/docker/)  


To run the default configuration:
```
docker build -t mycontainer/openfoam -f /path/to/Dockerfile . 
```
> NOTES:  
> - `mycontainer/openfoam` is an example container name.
> - the `.` at the end of the build line is important! It tells Docker where your build context is located!
> - `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 
> - The `scripts` directory is required within the build context directory, and the contents will be copied into the container.

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/openfoam \
    -f /path/to/Dockerfile \
    --build-arg OPENFOAM_VERSION=master \
    --build-arg SCOTCH_VER=master \
    --build-arg PETSC_VER=main
    . 
```
## Running OpenFOAM in a Container
Both Docker and Singularity can be run interactively or as a single command.
To run the [OpenFOAM Benchmarks](/openfoam/README.md#running-openfoam-benchmarks), just replace the `<OpenFOAM Command>` the examples in [Running OpenFOAM Benchmarks](/openfoam/README.md#running-openfoam-benchmarks) section of the OpenFOAM readme. The commands can be run directly in an interactive session as well.

### Docker 

#### Docker Interactive
Launching Docker Container
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/openfoam  bash
```
#### Docker Single Command 
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/openfoam \
           <OpenFOAM Command> 
```

### Singularity  

To build a Singularity image from the locally created docker file do the following:
```
singularity build openfoam.sif docker-daemon://mycontainer/openfoam:latest
```

#### Singularity Interactive 
Launch a Singularity Image
```
singularity shell --writable-tmpfs \
                    --no-home \
                    --pwd /benchmark \
                    openfoam.sif
```

#### Singularity Single Command
```
singularity run --writable-tmpfs \
                    --no-home \
                    --pwd /benchmark \
                    openfoam.sif \
                    <OpenFOAM Command>
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
|OpenFOAM|GPL v3|[OpenFOAM](https://www.openfoam.com)<br />[OpenFOAM License](https://www.openfoam.com/documentation/licencing)|
|PETSc|BSD-2 Clause | [PETSc](https://petsc.org/)<br />[PETSc License](https://petsc.org/release/install/license/)|
|PETScFOAM|GPL V3|[PETSc4FOAM](https://develop.openfoam.com/modules/external-solver)|
|HYPRE|Apache V2.0/MIT|[HYPRE Licenses](https://github.com/hypre-space/hypre#license)|
|Scotch|CeCILL-C|[Scotch Web Page](https://www.labri.fr/perso/pelegrin/scotch/)<br /> [Scotch License](https://gitlab.inria.fr/scotch/scotch/-/blob/master/LICENSE_en.txt)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

See the [OpenFOAM official page](https://www.openfoam.com/documentation/licencing) for more information on licensing.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
