# AMD's Implementation of Gromacs with HIP Docker Build
Instructions on how to build a Docker Container with AMD's implementation of Gromacs.

## System Requirements
- Git
- Docker

## Inputs:
There are four possible arguments into the Docker build command:

- ### IMAGE
    Default: rocm/dev-ubuntu-20.04:5.3-complete  
    NOTE: The -complete version has all the components required for building and installation.  
    If you want to use a different version of ROCm or Ubuntu you can find the containers on Docker Hub:
    - [ROCm Ubuntu 22.04](https://hub.docker.com/r/rocm/dev-ubuntu-22.04)
    - [ROCm Ubuntu 20.04](https://hub.docker.com/r/rocm/dev-ubuntu-20.04)

- ### GROMACS_BRANCH
    Default: develop_2022_amd  
    Branch/Tag found: [AMD's implementation of Gromacs with HIP repo](https://github.com/ROCmSoftwarePlatform/Gromacs).

- ### MPI_ENABLED
    Default: off  
    Options: `off` or `on`
    If this option is set to off, UCX and Open MPI will not be installed, and the following two options will not be used.

- ### UCX_BRANCH
    Default: v1.13.1  
    Branch/Tag found: [UXC repo](https://github.com/openucx/ucx).

- ### OMPI_BRANCH
    Default: v4.1.4  
    Branch/Tag found: [OpenMPI repo](https://github.com/open-mpi/ompi).

## Building AMD's implementation of Gromacs with HIP Container:
Download the Dockerfile from [here](/gromacs-docker/Dockerfile)  
Download the benchmark files from [here](/gromacs-docker/benchmark/) 
Notes for building: 
- `mycontainer/gromacs-hip` will be the name of your local container.
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
See the page provided in the [AMD Gromacs with HIP Infinity Hub](https://www.amd.com/en/technologies/infinity-hub/gromacs) for detailed instructions on running the AMD's implementation of Gromacs with HIP Container benchmark.
When using these instructions, you will replace the docker container name (`amdih/gromacs:...`) in the `docker run` and `singularity build` commands with `mycontainer/gromacs-hip` (or whatever you named your container) to the container you built. 