# PyFR

## Overview
PyFR is an open-source Python based framework for solving advection-diffusion type problems on streaming architectures using the Flux Reconstruction approach of Huynh. The framework is designed to solve a range of governing systems on mixed unstructured grids containing various element types. Support for AMD hardware has been integrated into the PyFR project and can be found at [PyFR.org](https://www.pyfr.org/) and [PyFR GitHub](https://github.com/PyFR/PyFR).

## Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> Radeon Instinct MI50(S) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility |[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com/)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [Testing the ROCm Installation](https://rocm.docs.amd.com/en/latest/deploy/linux/install.html#post-install-actions-and-verification-process)

## Docker Container Build
These instructions use Docker to create an HPC Application Container.  
If you are not familiar with creating Docker builds, please see the available [Docker manuals and references](https://docs.docker.com/).

### Build System Requirements
- Git
- Docker

### Inputs
Possible `build-arg` for the Docker build command  

- #### IMAGE
    Default: `rocm/dev-ubuntu-22.04:5.4.2-complete`  
    Docker Tags found: 
    - [ROCm Ubuntu 22.04](https://hub.docker.com/r/rocm/dev-ubuntu-22.04)
    - [ROCm Ubuntu 20.04](https://hub.docker.com/r/rocm/dev-ubuntu-20.04)
    > Note:  
    > The `*-complete` version has all the components required for building and installation. 

- #### PYFR_BRANCH
    Default: `v1.15.0`  
    Branch/Tag found: [PyFr](https://github.com/PyFR/PyFR).

- #### UCX_BRANCH
    Default: `v1.14.0`  
    Branch/Tag found: [UXC repo](https://github.com/openucx/ucx).

- #### OMPI_BRANCH
    Default: `v4.1.5`  
    Branch/Tag found: [OpenMPI repo](https://github.com/open-mpi/ompi).


### Building Container
Download the contents of the [PyFR-docker directory](/pyfr-docker/)  

To run the default configuration:
```
docker build -t mycontainer/pyfr -f /path/to/Dockerfile . 
```
> Notes:  
>- `mycontainer/pyfr` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context, if you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.  

```
docker build \
    -t mycontainer/pyfr \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm/dev-ubuntu-20.04:5.5-complete \
    --build-arg UCX_BRANCH=master \
    --build-arg OMPI_BRANCH=main
    . 
```

## Running PyFR Container:
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

### Docker
To run the container interactively, run the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it mycontainer/pyfr bash
```

### Singularity 
Singularity, like Docker, can be used for running HPC containers.  
To create a Singularity container from your local Docker container, run the following command:
```
singularity build pyfr.sif  docker-daemon://mycontainer/pyfr:latest
```

Singularity can be used similar to Docker to launch interactive and non-interactive containers, as shown in the following example of launching a interactive run
```
singularity shell --no-home --writable-tmpfs --pwd /examples pyfr.sif
```
*For more details on Singularity please see their [User Guide](https://docs.sylabs.io/guides/3.7/user-guide/)*

### PyFR Examples
This container has several examples, the [PyFR Test Cases](https://github.com/PyFR/PyFR-Test-Cases.git) come directly from PyFR organization on github.

#### BSF
 The script will make PyFR boot up the benchmark, compile the GPU kernels, and execute the simulation.  
 The user can track progress through a built-in progress bar in the application.
```
/examples/bsf/run_bsf 
```
> NOTE: It is not possible to run the BFS input set with more than one GPU currently.

#### TGV
The script converts the mesh to a PyFR mesh first and compiles the GPU kernels, and executes the simulation.  
As a convenience, this is performed in the benchmark script which can be run using one or two GPUs.  
**1 GPU**
```
/examples/tgv/run_tgv 1
```
**2 GPU**
```
/examples/tgv/run_tgv 2
```

#### NACA0021
The script extracts, then converts the mesh to a PyFR mesh first, for multiple GPU runs it will partition the mesh, then compiles the GPU kernels, and executes the simulation.  
As a convenience, this is performed in the benchmark script which can be run using one to eight GPUs.  
**1 GPU**
```
/examples/tgv/run_tgv 1
```
**2 GPU**
```
/examples/tgv/run_tgv 2
```
**4 GPU**
```
/examples/tgv/run_tgv 4
```
**8 GPU**
```
/examples/tgv/run_tgv 8
```

#### PyFR Test Cases
The PyFR test cases have been already provided into the container, they are located at `/examples/PyFR-Test-Cases`, These examples must be run interactively. 
The instructions on how to run these test cases can be located at [PyFr Examples](https://pyfr.readthedocs.io/en/latest/examples.html).
> NOTES:
> - The examples use `cuda` be sure to replace this with `hip` to run with AMD GPUs.  
> - Paraview has not been included in the container  
> - Unstructured VTK (.vtu) files can be placed in a mounted directory to access them on host machine. See [Docker](https://docs.docker.com/storage/volumes/) or [Singularity](https://apptainer.org/user-docs/master/bind_paths_and_mounts.html) documentation for details on how to mount a directory into the container. 

### PyFR Examples Non-Interactive
#### Docker
To execute the BSF example in a non-interactive fashion, use the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it mycontainer/pyfr /examples/bsf/run_bsf
```

#### Singularity 
After building a singularity container, run the following to execute the BSF example using singularity in a non-interactive fashion:
```
singularity run --no-home --writable-tmpfs pyfr.sif /examples/bsf/run_bsf
```

> NOTE: For both Docker and Singularity, the bsf command can be replaced with the tgv or naca0021 command for the to run the desired example. 

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:  Ubuntu (License: Creative Commons CC-BY-SA version 3.0 UK license), PyFR (License: BSD-3 Clause), PyFR Test Cases Ubuntu (License: Creative Commons Attribution 4.0 license), PyFR (License: BSD-3 Clause), CMAKE (License: BSD-3 Clause), OpenMPI (License: BSD-3 Clause), ROCm (License: Custom/MIT/Apache V2.0/UIUC NCSA). Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
