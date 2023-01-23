# rocHPCG Docker Build
Instructions on how to build a Docker Container with rocHPCG.

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

- ### ROCHPCG_BRANCH
    Default: master  
    Branch/Tag found: [rocHPCG repo](https://github.com/ROCmSoftwarePlatform/rocHPCG).

- ### UCX_BRANCH
    Default: v1.13.1  
    Branch/Tag found: [UXC repo](https://github.com/openucx/ucx).

- ### OMPI_BRANCH
    Default: v4.1.4  
    Branch/Tag found: [OpenMPI repo](https://github.com/open-mpi/ompi).

## Building rocHPCG Container:
Download the Dockerfile from [here](/hpcg-docker/Dockerfile) 
Notes for building: 
- `mycontainer/rochpcg` will be the name of your local container.
- the `.` at the end of the build line is important! It tells Docker where your build context is located!
- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context, if you are building in the same directory it is not required. 

To run the default configuration:
```
docker build -t mycontainer/rochpcg -f /path/to/Dockerfile . 
```


To run a custom configuration, include one or more customized build-arg:
DISCLAIMER: This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/rochpcg \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm/dev-ubuntu-20.04:5.2.3-complete \
    --build-arg ROCHPCG_BRANCH=devel \
    --build-arg UCX_BRANCH=master \
    --build-arg OMPI_BRANCH=main \
    . 
```

## Running rocHPCG Container:
See the page provided in the [AMD rocHPCG Infinity Hub](https://www.amd.com/en/technologies/infinity-hub/hpcg) for detailed instructions on running the rocHPCG container benchmark.
When using these instructions, you will replace the docker container name (`amdih/rochpcg:...`) in the `docker run` and `singularity build` commands with `mycontainer/rochpcg` (or whatever you named your container) to the container you built. 