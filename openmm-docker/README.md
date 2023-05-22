# OpenMM
OpenMM is a high performance toolkit for molecular simulation.
| Publisher | Built By | Multi-GPU Support |
| --------- | -------- | ----------------- |
| AMD       | AMD      | Yes               |

## Overview
Use OpenMM as a library, or as an application. We include extensive language bindings for Python, C, C++, and even Fortran. The code is open source and actively maintained on GitHub, licensed under MIT and LGPL. Part of the Omnia suite of tools for predictive biomolecular simulation.
For more information about OpenMM, visit
* http://openmm.org/


## Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> Radeon Instinct MI50(S) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility |[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://docs.amd.com/)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [Testing the ROCm Installation](https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html#testing-the-rocm-installation)

## OpenMM Docker Build
Instructions on how to build a Docker Container with OpenMM.

### Build System Requirements
- Git
- Docker

### Inputs
Possible `build-arg` for the Docker build command  

- #### IMAGE
    Default: `rocm/dev-ubuntu-22.04:5.5-complete`  
    Docker Tags found: 
    - [ROCm Ubuntu 22.04](https://hub.docker.com/r/rocm/dev-ubuntu-22.04)
    - [ROCm Ubuntu 20.04](https://hub.docker.com/r/rocm/dev-ubuntu-20.04)
    > Note:  
    > The `*-complete` version has all the components required for building and installation.  

- #### OPENMM_BRANCH
    Default: `8.0.0`  
    Branch/Tag found: [OpenMM repo](https://github.com/openmm/openmm.git)  

- #### OPENMMHIP_BRANCH
    Default: `Master`  
    Branch/Tag found: [OpenMM repo](https://github.com/openmm/openmm.git)  


- #### UCX_BRANCH
    Default: `v1.14.0`  
    Branch/Tag found: [UXC repo](https://github.com/openucx/ucx)  

- #### OMPI_BRANCH
    Default: `v4.1.5`  
    Branch/Tag found: [OpenMPI repo](https://github.com/open-mpi/ompi)  

### Building OpenMM Container:
Download the [Dockerfile](/openmm-docker/Dockerfile)  

To run the default configuration:
```
docker build -t mycontainer/OpenMM -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/OpenMM` is an example container name.
>- the `.` at the end of the build line is important! It tells Docker where your build context is located!
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context, if you are building in the same directory it is not required. 


To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/openmm \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm/dev-ubuntu-20.04:5.5.0-complete \
    --build-arg OPENMM_BRANCH=main \
    --build-arg UCX_BRANCH=master \
    --build-arg OMPI_BRANCH=main \
    . 
```

## Running OpenMM Container
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

### Docker
To run the container interactively, run the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/openmm  bash
```

### Singularity
To build a singularity container from a docker container run the following command:
```
singularity build openmm.sif docker-daemon://mycontainer/openmm
```
To launch a singularity container interactively run the following command:
```
singularity shell --pwd /opt/openmm/examples/ --no-home --writable-tmpfs openmm.sif
```

### Executing Benchmarks
Once the container has been launched, there are several different benchmarks that can be run:
`gbsa`, `rf`, `pme`, `amoebagk`, `amoebapme`, `apoa1rf`, `apoa1pme`, `apoa1ljpme`, `amber20-dhfr`.  
Each benchmark can be run at `single`, `double`, or `mixed` precision. 

From the directory `/opt/openmm/examples/` these benchmark examples can be executed by the following, by substituting `$BENCHMARK_NAME` and `$PRECISION` for the desired combination. 
```
python3 benchmark.py --platform HIP --test $BENCHMARK_NAME --precision $PRECISION
```

To execute all of these benchmarks execute the following:
```
benchmarks=(gbsa rf pme amoebagk amoebapme apoa1rf apoa1pme apoa1ljpme amber20-dhfr)
precisions=(single mixed double)
for benchmark in "${benchmarks[@]}"; do
    for precision in "${precisions[@]}"; do
        python3 benchmark.py --platform HIP --test $benchmark --precision $precision
    done
done
```

>NOTE: 
> The following message will be returned: `/bin/sh: 1: nvidia-smi: not found.` When running the benchmarks using `run-benchmarks`, the benchmark script attempts to run `nvidia-smi` and will fail since this tool is not part of the ROCm runtime supporting AMD Instinct GPUs.  The output will include `nvidia-smi: not found` messages. This message can safely be ignored and there is no effect on the benchmark results.

### Run Benchmark Non-Interactive

#### Docker
These can be executed using the same method as in the [Executing Benchmarks section](#executing-benchmarks)
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/openmm \
           python3 benchmark.py --platform HIP --test $BENCHMARK_NAME --precision $PRECISION
```

#### Singularity
Run the following command:
```
singularity run --pwd /opt/openmm/examples/ \
    --no-home \
    --writable-tmpfs \
    openmm.sif \
    python3 benchmark.py --platform HIP --test $BENCHMARK_NAME --precision $PRECISION
```

### Custom Simulation
To run a custom simulation, included any scripts and data files in the container at build time adding [Docker Copy](https://docs.docker.com/engine/reference/builder/#copy) commands in the provided [Dockerfile](/openmm-docker/Dockerfile) or mounting the files into the container at runtime with [Docker Volumes](https://docs.docker.com/storage/volumes/) or [Singularity Mount](https://docs.sylabs.io/guides/3.0/user-guide/bind_paths_and_mounts.html). 

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any sub-component in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components: Ubuntu (License: Creative Commons CC-BY-SA version 3.0 UK license), CMAKE (License: BSD 3), OpenMPI (License: BSD 3-Clause), OpenUCX (License: BSD 3-Clause), ROCm (License: Custom/MITx11/Apache V2.0/UIUC NCSA), OpenMM (License: MIT). Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
