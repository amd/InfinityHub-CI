
## OpenMM Docker Build
Instructions on how to build a Docker Container with OpenMM.


## Build System Requirements
- Git
- Docker

## Inputs
Possible `build-arg` for the Docker build command  

- ### IMAGE
    Default: `rocm_gpu:5.7`  
    > ***Note:***  
    >  This container needs to be build using [Base ROCm GPU](/base-gpu-mpi-rocm-docker/Dockerfile).

- ### OPENMM_BRANCH
    Default: `8.0.0`  
    Branch/Tag found: [OpenMM repo](https://github.com/openmm/openmm.git)  

- ### OPENMMHIP_BRANCH
    Default: `Master`  
    Branch/Tag found: [OpenMM repo](https://github.com/openmm/openmm.git)  

## Building OpenMM Container:
Download the [Dockerfile](/openmm/docker/Dockerfile)  

To run the default configuration:
```
docker build -t mycontainer/OpenMM -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/OpenMM` is an example container name.
>- the `.` at the end of the build line is important! It tells Docker where your build context is located!
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 


To run a custom configuration, include one or more customized build-arg  
*DISCLAIMER:* This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/openmm \
    -f /path/to/Dockerfile \
    --build-arg OPENMM_BRANCH=main
    . 
```
## Running OpenMM Container
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.  


To run the [OpenMM Benchmarks](/openmm/README.md#running-openmm-benchmarks), just replace the `<OpenMM Command>` the examples in [Running OpenMM Benchmarks](/openmm/README.md#running-openmm-benchmarks) section of the OpenMM readme. The commands can be run directly in an interactive session as well. 


### Docker  

#### Docker Interactive
To run the container interactively, run the following command:
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/openmm  bash
```
#### Docker Single Command
To run the container as part of a batch script in a single command
```
docker run --device=/dev/kfd \
           --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it  mycontainer/openmm \
           <OpenMM Command>
```


### Singularity  
To build a singularity container from a docker container run the following command:
```
singularity build openmm.sif docker-daemon://mycontainer/openmm
```

#### Singularity Interactive
To launch a singularity container interactively run the following command:
```
singularity shell \
    --pwd /opt/openmm/examples/ \
    --no-home \
    --writable-tmpfs \
    openmm.sif
```

#### Singularity Single Command
Run the following command:
```
singularity run \
    --pwd /opt/openmm/examples/ \
    --no-home \
    --writable-tmpfs \
    openmm.sif \
    <OpenMM Command>
```

## Custom Simulation
To run a custom simulation, included any scripts and data files in the container at build time adding [Docker Copy](https://docs.docker.com/engine/reference/builder/#copy) commands in the provided [Dockerfile](/openmm/docker/Dockerfile) or mounting the files into the container at runtime with [Docker Volumes](https://docs.docker.com/storage/volumes/) or [Singularity Mount](https://docs.sylabs.io/guides/3.0/user-guide/bind_paths_and_mounts.html). 
