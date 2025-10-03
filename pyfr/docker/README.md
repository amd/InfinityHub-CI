# PyFR Docker Build Instructions

## Overview
These instructions use Docker to create an HPC Application Container.  
If you are not familiar with creating Docker builds, please see the available [Docker manuals and references](https://docs.docker.com/).

## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:7.0`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

- ### PYFR_BRANCH
    Default: `v1.15.0`  
    Branch/Tag found: [PyFr](https://github.com/PyFR/PyFR).

## Building Container
Download the contents of the [PyFR-docker directory](/pyfr-docker/)  

To run the default configuration:
```
docker build -t mycontainer/pyfr -f /path/to/Dockerfile . 
```
> Notes:  
>- `mycontainer/pyfr` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.  

```
docker build \
    -t mycontainer/pyfr \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm_gpu:7.0 \
    --build-arg ARG PYFR_BRANCH=master \
    . 
```


## Running PyFR Container
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

To run the [PyFR Benchmarks](/pyfr/README.md#running-pyfr-benchmark), just replace the `<PyFR Command>` the examples in [Running PyFR Benchmarks](/pyfr/README.md#running-pyfr-benchmark) section of the PyFR readme. The commands can be run directly in an interactive session as well. 



### Docker  

#### Docker Interactive Container
To run the container interactively, run the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it mycontainer/pyfr bash
```
#### Docker Single Command
To run the container in a single command, as if in a batch script
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it mycontainer/pyfr \
           <PyFR Command>
```


### Singularity  
Singularity, like Docker, can be used for running HPC containers.  
To build a Singularity container from your local Docker container, run the following command
```
singularity build pyfr.sif  docker-daemon://mycontainer/pyfr:latest
```


#### Singularity Interactive  
To launch a Singularity image build locally into an interactive session.
```
singularity shell \
    --no-home \
    --writable-tmpfs \
    --pwd /examples \
    pyfr.sif
```

#### Singularity Single Command 
To launch a Singularity image build locally, as part of a batch script. 
```
singularity run --no-home --writable-tmpfs pyfr.sif <PyFR Command> 
```

*For more details on Singularity please see their [User Guide](https://docs.sylabs.io/guides/3.7/user-guide/)*
