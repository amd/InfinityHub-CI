## Overview
HPL-MxP solves a dense linear system of equations by using a low-precision LU factorization followed by iterative refinement. Similar to HPL, its more famous cousin, HPL-MxP uses a processor grid for load balancing across MPI ranks. The matrix of size N is tiled into blocks of size B which are cyclically distributed across a processor grid with P rows and Q columns. P is an explicit input argument while Q is deduced from P and the total number of MPI ranks, i.e. Q = n/P. HPL-MxP requires that P is a multiple of the number of MPI ranks n, and that matrix size N is a multiple of block size B. Note that the application is designed for parallel runs and requires at least 4 GPUs/GCDs to meet the requirements P>=2 && Q>=2.
> **NOTE**  
> formally known as hpl-ai
## System Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Build/Run Tools | 
| --- | --- | --- | --- | --- |
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> Radeon Instinct MI50(S) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility |[Spack](https://spack.io)<br>[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Running rocHPL
### Docker
Download the [rocHPL Docker script and other build code](/hpl-mxp/docker) if you want build a Docker Container version of the code.

The Docker image can be built using the provided Dockerfile source file. Starting in the directory that contains the `docker` directory, issue the command:
```
docker build -t hpl-mxp.6.0 -f Dockerfile .
```
Please note that the period (dot) at the end of the command is actually part of the docker build syntax and must be included in your command.

This will build a Docker image named (tagged) hpl-mxp.6.0, from the input file Docker/dockerfile, starting in the current directory (".").

## Running rocHPL-MxP

### Using Docker

To run the container interactively, run 

`docker run --device=/dev/kfd \
--device=/dev/dri \
--security-opt seccomp=unconfined \
--net=host \
-it amdih/hpl-ai:1.0.0 bash`

and launch any hpl-ai run command from the prompt. For non-interactive runs, simply replace bash with the hpl-ai run command

`docker run \
--device=/dev/kfd \
--device=/dev/dri \
--net=host \
-it amdih/hpl-ai:1.0.0 \
<hpl-ai run command> `

### Using Singularity

Download and save singularity image locally:

singularity pull hpl-ai.sif docker://amdih/hpl-ai:1.0.0

Using singularity is similar to launching an interactive Docker run

singularity run --pwd /benchmark hpl-ai.sif <hpl-ai run command>

Examples of hpl-ai run commands are described in the following section.

### Performance Evaluation
HPL-MxP reports the apparent FLOPS associated with the direct solve of a dense linear system.

`FLOPS = (2/3N^3 + 3/2N^2)/runtime`

In reality, the number of FLOPS is somewhat higher as additional operations take place in the iterative refinement steps required to bring the accuracy of the solution to double precision. HPL-MxP also reports the residual at the end of the refinement steps to allow the user to verify that double precision accuracy has been obtained.

In general, HPL-MxP performance will increase with matrix size and the benchmark is typically scaled so that the global matrix fills most of the available GPU memory. Optimal parameters depend on the system. Examples of parameters on AMD Instinct GPUs:

### MI100

4 GCD: mpirun -np 4 --map-by node:PE=1 hpl-ai -P 2 -B 2560 -N 168960
8 GCD: mpirun -np 8 --map-by node:PE=1 hpl-ai -P 4 -B 2560 -N 235520

### MI210/MI250/MI250X

4 GCD: mpirun -np 4 --map-by node:PE=1 hpl-ai -P 2 -B 2560 -N 235520
8 GCD: mpirun -np 8 --map-by node:PE=1 hpl-ai -P 4 -B 2560 -N 332800



# Synopsis
 ` mpirun -n <numprocs> [mpiarguments] hpl-ai -P <numprocrows> -B <block_size> -N <matrix_size> [arguments]`
 ### MPI arguments:
 --map-by numa:PE=1
 
 ### HPL-MxP arguments:
 -P The first dimension of the process grid. Requires mod(numprocs,P) = 0.
 -B The block size. Requires mod(N,B) = 0, otherwise code will adjust N automatically.
 -N The matrix size.

2) MPI Environment Variables
MPI environment variables have been set inside the container for ease of use while executing using Docker and/or multiple GPUs.

OMPI_MCA_pml=ucx
OMPI_ALLOW_RUN_AS_ROOT=1
OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
3) Example Command
For reference, the following is an example command line and output for a run of the HPL-MxP command on a node with 4 MI210 GPUs. The results on any given system will vary and this output is provided only to demonstrate the information presented on a successful run of the benchmark.

` mpirun -np 4 --map-by numa:PE=1 hpl-ai -N 235520 -B 2560 -maxits 3 -numa 2 -pmap cont2d `

The Figure of Merit (FoM) is the overall performance in Flops.


## Running Containers
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system. If needed, please consult with your system administrator or view official documentation.


### Advanced performance tuning
While the above limited set of arguments give decent performance across systems with Infinity Fabric, additional tuning may give even better results. HPL-MxP provides several command line options which combined with MPI arguments and UCX environment variables can have significant impact on performance. This is particularly true when high-speed intra-GPU communication is not available. The following lists a combination of settings that have worked well on systems limited to communication across PCIe.

MPI/UCX arguments:
--mca pml ucx
--map-by numa:PE=1
-x UCX_RNDV_PIPELINE_SEND_THRESH=256k
-x UCX_RNDV_FRAG_SIZE=rocm:4m
-x UCX_RNDV_THRESH=128
-x UCX_TLS=sm,self,rocm_copy,rocm_ipc

HPL-MxP arguments:
-P The first dimension of the process grid. Requires mod(numprocs,P) = 0.
-B The block size. Requires mod(N,B) = 0, otherwise code will adjust N automatically.
-N The matrix size.
-numa 2 Set the number of numa processes
-pmap CONT2D How to allocate numa-processes on the processor grid

For a complete list of hpl-ai arguments, see hpl-ai -hidden_help.

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/release/licensing.html)|
|Trilinos|BSD 3-Clause, LGPL|[hpl-mxp](https://github.com/trilinos/Trilinos)<br >[hpl-ai License]([https://trilinos.github.io/license.html](https://github.com/wu-kan/HPL-AI))|



Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
