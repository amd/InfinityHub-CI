# CP2K
CP2K is a quantum chemistry and solid state physics software package that can perform atomistic simulations of solid state, liquid, molecular, periodic, material, crystal, and biological systems. CP2K provides a general framework for different modeling methods such as [DFT](http://en.wikipedia.org/wiki/Density_functional_theory) using the mixed [Gaussian and plane waves approaches GPW and GAPW](https://www.cp2k.org/quickstep#gpw). Supported theory levels include DFTB, LDA, GGA, MP2, RPA, semi-empirical methods (AM1, PM3, PM6, RM1, MNDO, …), and classical force fields (AMBER, CHARMM, …). CP2K can do simulations of molecular dynamics, metadynamics, Monte Carlo, Ehrenfest dynamics, vibrational analysis, core level spectroscopy, energy minimization, and transition state optimization using NEB or dimer method. Detailed overview of features may be found at the [CP2K site](https://www.cp2k.org/features).

CP2K is written in Fortran 2008 and can be run efficiently in parallel using a combination of multi-threading, MPI, and HIP/CUDA. The CP2K software package is [freely available](https://www.cp2k.org/download) under the GPL license at https://www.cp2k.org.

For more information about CP2K, see www.cp2k.org.

For more information on the ROCm™ open software platform and access to an active community discussion on installing, configuring, and using ROCm, please visit the ROCm web pages at www.AMD.com/ROCm and [ROCm Community Forum](https://community.amd.com/t5/rocm/ct-p/amd-rocm).

The latest CP2K review, as of **May 2020**, can be found at **[The Journal of Chemical Physics 10.1063/5.0007045](https://doi.org/10.1063/5.0007045).**

## Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> Radeon Instinct MI50(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility |[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation)
* [Testing the ROCm Installation](https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html#testing-the-rocm-installation)

## Build CP2K Container
This section describes the instructions for building a Docker container with CP2K.

### Build System Requirements
- Git
- Docker


### Inputs
Possible `build-arg` for the Docker build command  

- #### IMAGE
    Default: `rocm/dev-ubuntu-20.04:5.4.3-complete`  
    Docker Hub Tags found: 
    - [ROCm Ubuntu 22.04](https://hub.docker.com/r/rocm/dev-ubuntu-22.04)
    - [ROCm Ubuntu 20.04](https://hub.docker.com/r/rocm/dev-ubuntu-20.04)
    > Note:  
    > The `*-complete` version has all the components required for building and installation.  
    
    

- #### CP2K_BRANCH
    Default: `v2023.1`  
    Branch/Tag found: [CP2K repo](https://github.com/cp2k/cp2k)

- #### UCX_BRANCH
    Default: `v1.14.0`   
    Branch/Tag found: [UCX repo](https://github.com/openucx/ucx)

- #### OMPI_BRANCH
    Default: `v4.1.4`  
    Branch/Tag found: [OpenMPI repo](https://github.com/open-mpi/ompi)

- #### GPU_VER
    Default: `Mi250`   
    Options: `Mi50`, `Mi100`, `Mi250`  
    Specifies the GPU architecture for which DBCSR will be built. Mi250 is used for all MI200 series accelerators.


### Build Instructions
Download the [CP2K Dockerfile](/cp2k-docker/Dockerfile).

To build the default configuration:
```
docker build -t mycontainer/cp2k -f /path/to/Dockerfile . 
```
>Notes:  
>- `mycontainer/cp2k` will be the name of your local container.
>- the `.` at the end of the build line is important! It tells Docker where your build context is located.
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context.


To run a custom configuration, include one or more customized `--build-arg` parameter.  
*DISCLAIMER*: This Docker build has only been validated using the default values. Using a different base image or branch may result in build failures or poor performance.
```
docker build \
    -t mycontainer/cp2k \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm/dev-ubuntu-20.04:5.2.3-complete \
    --build-arg CP2K_BRANCH=master \
    --build-arg UCX_BRANCH=v1.8.0 \
    --build-arg OMPI_BRANCH=v4.0.3 \
    --build-arg GPU_VER=Mi100 \
    . 
```

## Run CP2K Container
### Interactive

#### Docker 
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined --ipc=host -e PMIX_MCA_gds=^ds21 mycontainer/cp2k /bin/bash
```
#### Singularity 
To build a Singularity image from the locally created docker file do the following:
```
singularity build cp2k.sif docker-daemon://mycontainer/cp2k:latest
```
To launch a Singularity image build locally
```
singularity shell --no-home --writable-tmpfs cp2k.sif
```

#### A Note on CP2K Executables

In this container, you will find two CP2K executables, each tuned for different sets of benchmarks.  
- For RPA Benchmarks:`cp2k.psmp.no_dbcsr_gpu`  
    This executable has been built without the DBCSR GPU backend as it improves the performance of Random Phase Approximation (RPA) benchmarks.
- For DFT Benchmarks:`cp2k.psmp.no_pw_gpu`  
    This executable has been built without the PW GPU backend as it improves the performance of Linear Scaling Density Functional Theory (LS-DFT) benchmarks.

##### Running CP2K benchmarks on MI210/MI100 GPUs

The following command can be used to run the [H2O-DFT-LS (NREP2)](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp) benchmark with 8 GPUs:

```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=8 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_pw_gpu \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-8GPU.txt
```

In the above example, the H2O-DFT-LS (NREP2) benchmark is run on a dual socket server with 8 MI210 GPUs and 128 physical cores. The job in this example is run with 16 MPI ranks and 8 OpenMP threads per rank with two processes sharing a GPU. The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust these parameters accordingly.

A grep for `"CP2K     "` in the output file `/tmp/H2O-DFT-LS-NREP2-8GPU.txt` will show the elapsed time for the run.

The following command can be used to run the [H2O-DFT-LS (NREP2)](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp) benchmark with 4 GPUs:
```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=4 \
    -x RANK_STRIDE=4 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_pw_gpu \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-4GPU.txt
```
In the above example, the H2O-DFT-LS (NREP2) benchmark is run a dual socket server that has 8 MI210 GPUs and 128 physical cores, but uses only 64 physical cores of one socket and 4 MI210 GPUs. The job in this example is run with 16 MPI ranks and 4 OpenMP threads per rank with two processes sharing a GPU. The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. Setting `RANK_STRIDE` to 4 allows the processes and their threads to be spread out and pinned to physical cores on the socket. If your system has a different configuration, please adjust the parameters accordingly.

A grep for `"CP2K     "` in the output file `/tmp/H2O-DFT-LS-NREP2-4GPU.txt` will show the elapsed time for the run.

The following commands can be used to run the [32-H2O-RPA](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/) benchmark. There are two steps involved in this benchmark namely the `init` and `solver` stages. The init stage will use the [H2O-32-PBE-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-PBE-TZ.inp) input file and the solver stage will use the [H2O-32-RI-dRPA-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-RI-dRPA-TZ.inp) input file.

>Note:  
>For this benchmark it is necessary to run from the `/opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O` directory due to file dependencies between the two stages.

First run the init stage:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=1 \
    -x RANK_STRIDE=4 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 4 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_dbcsr_gpu \
    -i H2O-32-PBE-TZ.inp \
    -o /tmp/32-H2O-RPA-init-1GPU.txt
```

Next, run the solver stage:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=8 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_dbcsr_gpu \
    -i H2O-32-RI-dRPA-TZ.inp \
    -o /tmp/32-H2O-RPA-solver-8GPU.txt
```

In the above example, the two stages of the 32-H2O-RPA benchmark are run on a dual socket server with 8 MI210 GPUs and 128 physical cores. The init step is run with 4 MPI ranks and 4 OpenMP threads per rank on 1 GPU with all 4 ranks sharing the GPU. The solver step is run with 16 MPI ranks and 8 OpenMP threads per rank on 8 GPUs with two processes sharing a GPU. The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust the parameters accordingly.

A grep for `"CP2K     "` in the output files `/tmp/32-H2O-RPA-*.txt` will show the elapsed time for each run.

>Note:  
>The above-mentioned commands can also be run verbatim on a dual socket server with 8 MI100 GPUs and 128 physical CPU cores. If your system configuration is different, please adjust the parameters accordingly.

##### Running CP2K benchmarks on MI250 GPUs

An MI250 GPU contains two Graphics Compute Dies (GCDs) each of which is presented to the application
as a separate GPU device. When running with MI250 GPUs, the scripts that set up CPU and GPU affinities,
namely `set_cpu_affinity.sh` and `set_gpu_affinity.sh`, require 
`NUM_GPUS` to be set up with the number of GCDs we want to run with.
In this section, we show how to run CP2K benchmarks on 1 and 4 MI250 GPUs which would translate
to setting `NUM_GPUS` with 2 and 8 respectively.

All the examples provided in this section show benchmarks run on a dual socket server with 4 MI250 GPUs and 128 physical cores.

The following command can be used to run the [H2O-DFT-LS (NREP2)](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp) benchmark on 16 physical CPU cores and 1 MI250 GPU with 4 MPI ranks and 4 OpenMP threads per rank with two processes sharing each GCD:
```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=2 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 4 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_pw_gpu \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-1GPU.txt
```

The following command can be used to run the H2O-DFT-LS (NREP2) benchmark on 64 physical cores and 4 MI250 GPUs with 16 MPI ranks and 4 OpenMP threads per rank with two processes sharing each GCD:
```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_pw_gpu \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-4GPU.txt
```

The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust these parameters accordingly.

A grep for `"CP2K     "` in the output file `/tmp/H2O-DFT-LS-NREP2-*.txt` will show the elapsed time for each run.

The following commands can be used to run the [32-H2O-RPA](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/) benchmark on MI250 GPUs. There are two steps involved in this benchmark namely the `init` and `solver` stages. The init stage will use the [H2O-32-PBE-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-PBE-TZ.inp) input file and the solver stage will use the [H2O-32-RI-dRPA-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-RI-dRPA-TZ.inp) input file.

>Note:  
>For this benchmark it is necessary to run from the `/opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O` directory due to file dependencies between the two stages.*

First, the init step is run with 4 MPI ranks and 4 OpenMP threads per rank on 1 MI250 GPU (2 GCDs) with 2 ranks sharing each GCD:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=2 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 4 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_dbcsr_gpu \
    -i H2O-32-PBE-TZ.inp \
    -o /tmp/32-H2O-RPA-init-1GPU.txt
```

Next, the solver step may be run on 1 MI250 GPU with 8 MPI ranks and 2 OpenMP threads per rank with 4 processes sharing each GCD:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=2 \
    -x RANK_STRIDE=4 \
    -x OMP_NUM_THREADS=2 \
    --oversubscribe \
    -np 8 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_dbcsr_gpu \
    -i H2O-32-RI-dRPA-TZ.inp \
    -o /tmp/32-H2O-RPA-solver-1GPU.txt
```

Or the solver step may be run on 4 MI250 GPUs using 16 MPI ranks and 4 OpenMP threads per rank with 2 processes sharing each GCD:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp.no_dbcsr_gpu \
    -i H2O-32-RI-dRPA-TZ.inp \
    -o /tmp/32-H2O-RPA-solver-4GPU.txt
```

In the above-mentioned commands, the `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust the parameters accordingly.

A grep for `"CP2K     "` in the output files `/tmp/32-H2O-RPA-*.txt` will show the elapsed time for each run.

### Non-interactive

#### Docker

The same H2O-DFT-LS (NREP2) benchmark with 8 GPUs can run from the command line as follows:
```
docker run \
    --rm \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --ipc=host \
    -e NUM_CPUS=128 \
    -e NUM_GPUS=8 \
    -e RANK_STRIDE=8 \
    -e OMP_NUM_THREADS=8 \
    -e PMIX_MCA_gds=^ds21 \
    -v $(pwd):/tmp/ \
    mycontainer/cp2k:latest \
    bash -c """ \
    mpirun \
        --oversubscribe \
        -np 16 \
        --bind-to none \
        set_cpu_affinity.sh \
        set_gpu_affinity.sh \
        cp2k.psmp.no_pw_gpu \
        -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
        -o /tmp/H2O-DFT-LS-NREP2-8GPU-docker.txt \
    """
```

#### Singularity
To run the same benchmark using Singularity, type:
```
SINGULARITYENV_NUM_CPUS=128 \
SINGULARITYENV_NUM_GPUS=8 \
SINGULARITYENV_RANK_STRIDE=8 \
SINGULARITYENV_OMP_NUM_THREADS=8 \
singularity exec \
    --no-home \
    --writable-tmpfs \
    --pwd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O \
    --bind $(pwd):/tmp/ \
    cp2k.sif \
    bash -c \
    """ \
    mpirun \
        --oversubscribe \
        -np 16 \
        --bind-to none \
        set_cpu_affinity.sh \
        set_gpu_affinity.sh \
        cp2k.psmp.no_pw_gpu \
        -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
        -o /tmp/H2O-DFT-LS-NREP2-8GPU-singularity.txt \
    """
```

## Licensing Information

Your use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components: Ubuntu (License: Creative Commons CC-BY-SA version 3.0 UK license), CP2K (GNU GPL version 2 or, at your option, any later version), CMAKE (License: BSD 3), OpenMPI (License: BSD 3-Clause), OpenUCX (License: BSD 3-Clause), ROCm (License: Custom/MIT/Apache V2.0/UIULC OSL), OpenBLAS (License: BSD 3-Clause), COSMA (License: BSD 3-Clause), Libxsmm (License: BSD 3-Clause), Libxc (License: MPL v2.0), SpLA (License: BSD 3-Clause). Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.
 
## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

 
## Notices and Attribution
© 2022-23 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

