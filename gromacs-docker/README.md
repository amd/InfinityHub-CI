# GROMACS
This AMD Container is based on the 2022 release of GROMACS modified by AMD. This container only supports up to an 8 GPU configuration.


## Overview
---
GROMACS is a versatile package to perform molecular dynamics, i.e. simulate the Newtonian equations of motion for systems with hundreds to millions of particles. It is primarily designed for biochemical molecules like proteins, lipids and nucleic acids that have a lot of complicated bonded interactions, but since GROMACS is extremely fast at calculating the nonbonded interactions (that usually dominate simulations) many groups are also using it for research on non-biological systems, e.g. polymers.
For more information about GROMACS, visit [gromacs.org](https://www.gromacs.org).

For more information on the ROCm™ open software platform and access to an active community discussion on installing, configuring, and using ROCm, please visit the ROCm web pages at www.AMD.com/ROCm and [ROCm Community Forum](https://community.amd.com/t5/rocm/ct-p/amd-rocm)
Note:
- This container is based on a fork of the GROMACS project written for AMD GPUs - it is not an official release by the GROMACS team;
- This container is not developed by the GROMACS team;
- This container is not maintained or supported by the GROMACS team;
- The source of the GROMACS fork is publicly available here: https://github.com/ROCmSoftwarePlatform/Gromacs


## Single-Node Server Requirements
---

| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> Radeon Instinct MI50(S) | Ubuntu 20.04 <br> UbuntU 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility |[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

Note: The GROMACS application container assumes that the server contains the required x86-64 CPU(s) and at least one of the listed AMD GPUs. Also, the server must have one of the required operating systems and the listed ROCm driver version installed to run the Docker container. The server must also have a Docker Engine installed to run the container. Please visit the Docker Engine install web site at https://docs.docker.com/engine/install/ to install the latest Docker Engine for the operating system installed on the server. If Singularity use is planned, please visit https://sylabs.io/docs/ for the latest Singularity install documentation
Please visit https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html for ROCm installation procedures and validation checks.
 
## AMD's Implementation of Gromacs with HIP Docker Build
---
Instructions on how to build a Docker Container with AMD's implementation of Gromacs.

### Build System Requirements
- Git
- Docker

### Inputs:
There are four possible arguments into the Docker build command:

- #### IMAGE
    Default: rocm/dev-ubuntu-20.04:5.3-complete  
    NOTE: The -complete version has all the components required for building and installation.  
    If you want to use a different version of ROCm or Ubuntu you can find the containers on Docker Hub:
    - [ROCm Ubuntu 22.04](https://hub.docker.com/r/rocm/dev-ubuntu-22.04)
    - [ROCm Ubuntu 20.04](https://hub.docker.com/r/rocm/dev-ubuntu-20.04)

- #### GROMACS_BRANCH
    Default: develop_2022_amd  
    Branch/Tag found: [AMD's implementation of Gromacs with HIP repo](https://github.com/ROCmSoftwarePlatform/Gromacs).

- #### MPI_ENABLED
    Default: off  
    Options: `off` or `on`
    If this option is set to off, UCX and Open MPI will not be installed, and the following two options will not be used.

- #### UCX_BRANCH
    Default: v1.13.1  
    Branch/Tag found: [UXC repo](https://github.com/openucx/ucx).

- #### OMPI_BRANCH
    Default: v4.1.4  
    Branch/Tag found: [OpenMPI repo](https://github.com/open-mpi/ompi).

### Building AMD's implementation of Gromacs with HIP Container:
Download the Dockerfile from [here](/gromacs-docker/Dockerfile)  
Download the benchmark files from [here](/gromacs-docker/benchmark/) 
Notes for building: 
- `mycontainer/gromacs-hip` is an example container name. 
- the `.` at the end of the build line is important! It tells Docker where your build context is located!
- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context, if you are building in the same directory it is not required. 
- The `benchmark` directory is required within the build context directory, and the contents will be copied into the container. We have provided three benchmarks, and instructions on how to run them ([see below](#running-amd-implementation-of-gromacs-with-hip-container)). If you plan on running AMD's implementation of Gromacs with HIP against your own data set, it can be copied into the container by placing it in the benchmark directory before building or mounted into the container using dockers mount/volume API. 

To run the default configuration:
```
docker build -t mycontainer/gromacs-hip -f /path/to/Dockerfile . 
```


To run a custom configuration, include one or more customized build-arg:
DISCLAIMER: This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/gromacs-hip \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm/dev-ubuntu-20.04:5.2.3-complete \
    --build-arg GROMACS_BRANCH=develop_stream_2022-09-16 \
    --build-arg MPI_ENABLED=on \
    --build-arg UCX_BRANCH=master \
    --build-arg OMPI_BRANCH=main \
    . 
```

## Running AMD implementation of Gromacs with HIP Container:
---
Start an interactive session from host:

```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined mycontainer/gromacs-hip /bin/bash
```
 
Run appropriate benchmark problem using commands provided below.  Note that in some cases the offloading of bonds to GPUs (`-bonded gpu`) is not recommended for optimal performance.  

### EXAMPLE WITH THREADED MPI 
**ADH_DODEC**
```
cd /benchmarks/adh_dodec
tar -xvf adh_dodec.tar.gz
```
Using one GPU (or GCD)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 1 -ntomp 64 -noconfout -nb gpu -bonded cpu -pme gpu -v -nstlist 100 -gpu_id 0 -s topol.tpr
```
 
Using two GPUs(or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 2 -ntomp 32 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 200 -gpu_id 01 -s topol.tpr
```
 
Using four GPUs (or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 200 -gpu_id 0123 -s topol.tpr
```
Using eight GPUs (or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 150 -gpu_id 01234567 -s topol.tpr
```

**CELLULOSE_NVE**
```
cd /benchmarks/cellulose_nve
tar -xvf cellulose_nve.tar.gz
```

Using one GPU (or GCD)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 1 -ntomp 64 -noconfout -nb gpu -bonded cpu -pme gpu -v -nstlist 100 -gpu_id 0 -s topol.tpr
```
 
Using two GPUs(or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 200 -gpu_id 01 -s topol.tpr
```
 
Using four GPUs (or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 200 -gpu_id 0123 -s topol.tpr
```

Using eight GPUs (or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 200 -gpu_id 01234567 -s topol.tpr
```

**STMV**
```
cd /benchmarks/stmv
tar -xvf stmv.tar.gz
```

Using one GPU (or GCD)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 1 -ntomp 64 -noconfout -nb gpu -bonded cpu -pme gpu -v -nstlist 200 -gpu_id 0 -s topol.tpr
```
 
Using two GPUs(or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 200 -gpu_id 01 -s topol.tpr
```
 
Using four GPUs (or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 400 -gpu_id 0123 -s topol.tpr
```
Using eight GPUs (or GCDs)
```
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -nstlist 400 -gpu_id 01234567 -s topol.tpr
```

### RUN USING SINGULARITY
This section assumes that an up-to-date version of Singularity is installed on your system. Please consult with your system administrator or view official Singularity documentations.

To create a Singularity container from your local Docker container, run the following command:
 
```
singularity build gromacs.sif docker-daemon://mycontainer/gromacs-hip
```
 
#### EXAMPLE STMV WITH THREADED MPI
 
```
singularity run ./gromacs.sif tar -xvf /benchmarks/stmv/stmv.tar.gz
singularity run ./gromacs.sif gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -v -gpu_id 01234567 -npme 1 -s topol.tpr -nstlist 400
```


### NOTE ON PERFORMANCE TUNING
Optimal performance for each benchmark and GPU/GCD configuration can be tuned by modifying the MPI ranks/threads (`-ntmpi`), OpenMP threads (`-ntomp`), GPUs (`-gpu_id`), neighbor list update frequency (`-nstlist`), and more. Users are encourage to visit Gromacs documentation for "[Getting good performance from **mdrun**](https://manual.gromacs.org/documentation/current/user-guide/mdrun-performance.html)" for further tips and tricks.


## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:  Ubuntu (License: Creative Commons CC-BY-SA version 3.0 UK license), Gromacs (License: LGPL 2.1), CMAKE (License: BSD 3), OpenMPI (License: BSD 3-Clause), OpenUCX (License: BSD 3-Clause), ROCm (License: Custom/MIT/Apache V2.0/UIUC NCSA). Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

The GROMACS source code and selected set of binary packages are available here: www.gromacs.org. GROMACS is Free Software, available under the GNU Lesser General Public License (LGPL), version 2.1. You can redistribute it and/or modify it under the terms of the LGPL as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale. AMD, the AMD Arrow logo and combinations thereof are trademarks of Advanced Micro Devices, Inc. Other product names used in this publication are for identification purposes only and may be trademarks of their respective companies.

## Notices and Attribution
© 2021-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
