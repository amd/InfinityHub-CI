# CP2K Container Build Instructions
This document provides instructions on how to build CP2K into a Docker container that is portable between environments.  
  

## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:6.4`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

> **NOTE**
> This recipe uses a script within the CP2K repo to install the all dependencies. The toolchain script does not directly support Mi300,
> The recipe has been updated to use the variable `AMDGPU_TARGETS`, set in the [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile), to determine what GPU architecture(s) to build for. The [Mi250](/cp2k/docker/Dockerfile#27) in the Dockerfile correctly configures the toolchain for all AMD GPUs, and the recipe updates the necessary details for the GPU(s) to build for. 

## Build Instructions
Download the [CP2K Dockerfile](/cp2k/docker/Dockerfile).

To build the default configuration:
```bash
docker build -t mycontainer/cp2k -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/cp2k` will be the name of your local container.
>- the `.` at the end of the build line is important! It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context.

To run a custom configuration, include one or more customized `--build-arg` parameter.  
*DISCLAIMER*: This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```bash
docker build \
    -t mycontainer/cp2k \
    -f /path/to/Dockerfile \
    --build-arg CP2K_BRANCH=master \
    --build-arg GPU_VER=Mi100 \
    . 
```

## Run CP2K Container

Both Docker and Singularity can be run interactively or as a single command.

To run the [CP2K Benchmarks](/cp2k/README.md#running-cp2k-benchmarks), just replace the `<cp2k Command>` the examples in [Running CP2K Benchmarks](/cp2k/README.md#running-cp2k-benchmarks) section of the CP2K readme. The commands can be run directly in an interactive session as well.
> **CP2K Executables**  
> In this container, you will find two CP2K executables, each tuned for different sets of benchmarks.  
>- For RPA Benchmarks:`cp2k.psmp.no_dbcsr_gpu`  
>    This executable has been built without the DBCSR GPU backend as it improves the performance of Random Phase Approximation (RPA) benchmarks.
>- For DFT Benchmarks:`cp2k.psmp.no_pw_gpu`  
>    This executable has been built without the PW GPU backend as it improves the performance of Linear Scaling Density Functional Theory (LS-DFT) benchmarks.
> To run this benchmarks you will need to update the command from [Running CP2K Benchmarks](/cp2k/README.md#running-cp2k-benchmarks) to use the binary specified. 


### Docker  
If you want access any output files generated during the run, please add `-v $(pwd):/tmp` before `mycontainer/cp2k` in the following commands. 
For interactive, be sure to copy any files to `/tmp` before exiting the container. For Single Command runs, you can set the output to `/tmp` or set your working directory using `--workdir /tmp`.
#### Docker Interactive
```bash
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined -e PMIX_MCA_gds=^ds21 mycontainer/cp2k /bin/bash
```

#### Docker Single Command
```bash
docker run --rm --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined -e PMIX_MCA_gds=^ds21 mycontainer/cp2k bash -c "<cp2k Command>"
```

### Singularity  
To build a Singularity image from the locally created docker file do the following:
```bash
singularity build cp2k.sif docker-daemon://mycontainer/cp2k:latest
```
#### Singularity Interactive
To launch a Singularity image build locally
```bash
singularity shell --no-home --writable-tmpfs cp2k.sif
```

#### Singularity Single Command
```bash
singularity run --no-home --writable-tmpfs cp2k.sif bash -c "<cp2k Command>"
```
> The `bash -c "<cp2k Command>"` Allows for multiple commands to be sent to the running container at once, which is required for some of the more complex CP2K benchmarks. 

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
|CP2K|GNU GPL Version 2|[CP2k](https://www.cp2k.org/)<br />[CP2K License](https://github.com/cp2k/cp2k/blob/master/LICENSE)|
|OpenBlas|BSD 3-Clause|[OpenBlas](https://www.openblas.net/)<br /> [OpenBlas License](https://github.com/xianyi/OpenBLAS/blob/develop/LICENSE)|
|COSMA|BSD 3-Clause|[COSMA License](https://github.com/eth-cscs/COSMA/blob/master/LICENSE)|
|Libxsmm|BSD 3-Classe|[Libxsmm License](https://libxsmm.readthedocs.io/en/latest/LICENSE/)|
|Libxc|MPL v2.0|[Libxc License](https://github.com/ElectronicStructureLibrary/libxc)|
|SpLA|BSD 3-Clause|[SpLA License](https://github.com/eth-cscs/spla/blob/master/LICENSE)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.
 
## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

 
## Notices and Attribution
© 2022-24 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

