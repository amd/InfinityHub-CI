# rocHPL

Instructions are provided to build rocHPL (HPL), using Spack (Lawrence Livermore National Laboratory, https://spack.io) as the package builder. Instructions for creating the Spack package using a Docker (Docker, Inc., https://docker.com) Container are also provided in this document. A pre-built rocHPL Docker Container will not be provided on AMD Infinity Hub. 

## Overview
HPL, or High-Performance Linpack, is a benchmark which solves a uniformly random system of linear equations and reports floating-point execution rate. This documentation supports the implementation of the HPL benchmark on top of AMD's ROCm platform.

## System Requirements
## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
|---- |---- |----------------- |------------ |------------------ | 
| X86_64 CPU(s) |[AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s)](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-gpus) | [Ubuntu <br> RHEL <br>  SLES  <br> Oracel Linux](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-operating-systems) | [ROCm Latest](https://rocm.docs.amd.com/en/latest/) | [Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |
## Dependencies 
The Dependencies for the build are:

- ### rocHPL source
    Location: [rocHPL Repo](https://github.com/ROCmSoftwarePlatform/rocHPL.git)  
    Branch: `main`

- ### UCX 
    Location: [UXC repo](https://github.com/openucx/ucx)  
    Branch: `v1.13.1`  

- ### Open MPI
    Location: [OpenMPI repo](https://github.com/open-mpi/ompi)  
    Branch: `v4.1.4`

## Building rocHPL
### Spack 
Download the [rocHPL Spack script and other build code](/rochpl/spack)


- `rochpl.package.py` contains the Spack specification for building rocHPL. This file points to the source, defines prerequisite packages and sets some build arguments.  Note that rochpl is currently defined externally from Spack, via the rochpl.package.py file and it will, eventually, be pushed to the standard Spack repository. 
- `bldRochpl.sh` is the script that will build the application. If you do not already have Spack installed, run the command to install Spack ( `git clone -c feature.manyFiles=true https://github.com/spack/spack.git`) starting in your home directory. Also, locate the file, `omp.h` (typically part of your standard compiler installation). Update the  HIPCC_COMPILE_FLAGS_APPEND variable to point to the directory containing `omp.h`.

To run the default Spack build for rocHPL:
```
./bldRochpl.sh
```
The build script is only a template for building the Spack application. You may need to edit the script for your own environment.

On the first run, the build will take multiple hours to build all the components. 

#### Locating the rocHPL Spack Image
Spack compiles and links code into fairly self contained packages using the Linux rpath facilities. The location of the built package may be found using the `spack location` command:
```
source  $HOME/spack/share/spack/setup-env.sh
spack location --install-dir rochpl
```
Use a symbolic link to create an easy to remember location, such as a "benchmark" directory (note the back ticks around the spack command):
```
ln -s `spack location --install-dir rochpl` benchmark
cd benchmark
```
Inside the `benchmark/bin` directory is the `mpirun_rochpl` script that is used to run the rochpl application. The PATH environment variable may be extended to put that directory on the active path:
`export PATH=$PWD/bin:$PATH`

### Docker
Download the [rocHPL Docker script and other build code](/rochpl/docker) if you want build a Docker Container version of the code.

The Docker image can be built using the provided Dockerfile source file. Starting in the directory that contains the `docker` directory, issue the command:
```
docker build -t rochpl.6.0 -f Dockerfile .
```
Please note that the period (dot) at the end of the command is actually part of the docker build syntax and must be included in your command.

This will build a Docker image named (tagged) rochpl.6.0, from the input file Docker/dockerfile, starting in the current directory (".").


## Running rocHPL
The  **rocHPL**  benchmark provides a helpful wrapper script in  `mpirun_rochpl`. This script has two distinct run modes:

1) All command line input

`mpirun_rochpl -P <P> -Q <P> -N <N> --NB <NB> -f <frac>  `
 where  
 P - is the number of rows in the MPI grid  
 Q - is the number of columns in the MPI grid  
 N - is the total number of rows/columns of the global matrix  
 NB - is the panel size in the blocking algorithm  
 frac - is the split-update fraction (important for hiding some MPI communication)

This run script will launch a total of np=PxQ MPI processes.

2) Input using a file 

The second run mode takes an input file together with a number of MPI processes:

`mpirun_rochpl -P <p> -Q <q> -i <input> -f <frac> ` 
 where  
 P - is the number of rows in the MPI grid  
 Q - is the number of columns in the MPI grid  
 input - is the input filename (default HPL.dat)  
 frac - is the split-update fraction (important for hiding some MPI communication)`

The input file accepted by the  `rochpl`  executable follows the format below:
```
HPLinpack benchmark input file  
Innovative Computing Laboratory, University of Tennessee  

HPL.out output file name (if any)  
0 device out (6=stdout,7=stderr,file)  
1 # of problems sizes (N)  
45312 Ns  
1 # of NBs  
512 NBs  
1 PMAP process mapping (0=Row-,1=Column-major)  
1 # of process grids (P x Q)  
1 Ps  
1 Qs  
16.0 threshold  
1 # of panel fact  
2 PFACTs (0=left, 1=Crout, 2=Right)  
1 # of recursive stopping criterium  
16 NBMINs (>= 1)  
1 # of panels in recursion  
2 NDIVs  
1 # of recursive panel fact.  
2 RFACTs (0=left, 1=Crout, 2=Right)  
1 # of broadcast  
0 BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)  
1 # of lookahead depth  
1 DEPTHs (>=0)  
1 SWAP (0=bin-exch,1=long,2=mix)  
64 swapping threshold  
1 L1 in (0=transposed,1=no-transposed) form  
0 U in (0=transposed,1=no-transposed) form  
0 Equilibration (0=no,1=yes)  
8 memory alignment in double (> 0)
```

### Performance Evaluation

The  **rocHPL**  benchmark is typically weak scaled so that the global matrix fills all available VRAM on all GPUs. The matrix size N is usually selected to be a multiple of the blocksize NB. Optimal parameters typically depend on the CPUs and GPUs of the system. Some example run lines for some AMD Instinct GPUs are the following:

#### MI100

1 GPU:  `mpirun_rochpl -P 1 -Q 1 -N 64000 --NB 512`  
2 GPU:  `mpirun_rochpl -P 1 -Q 2 -N 90112 --NB 512`  
4 GPU:  `mpirun_rochpl -P 2 -Q 2 -N 126976 --NB 512`  
8 GPU:  `mpirun_rochpl -P 2 -Q 4 -N 180224 --NB 512`

#### MI210/MI250/MI250X

1 GCD:  `mpirun_rochpl -P 1 -Q 1 -N 90112 --NB 512`  
2 GCD:  `mpirun_rochpl -P 2 -Q 1 -N 128000 --NB 512`  
4 GCD:  `mpirun_rochpl -P 2 -Q 2 -N 180224 --NB 512`  
8 GCD:  `mpirun_rochpl -P 2 -Q 4 -N 256000 --NB 512`  
16 GCD:  `mpirun_rochpl -P 4 -Q 4 -N 360448 --NB 512`

>Note:
> These are example command lines and optimal values may vary depending on system characteristics.

Overall performance of the benchmark is measured in 64-bit floating point operations (FLOPs) per second. Performance is reported at the end of the run to the user's specified output (by default the performance is printed to  **stdout**  and a results file  `HPL.out`).

### Testing rocHPL

At the end of each benchmark run, residual error checking is computed, and PASS or FAIL is printed to output.

The simplest suite of tests should run configurations from 1 to 4 GPUs to exercise different communication code paths. For example the tests should all report PASSED:
```
mpirun_rochpl -P 1 -Q 1 -N 43008  
mpirun_rochpl -P 1 -Q 2 -N 43008  
mpirun_rochpl -P 2 -Q 1 -N 43008  
mpirun_rochpl -P 2 -Q 2 -N 43008`
```
Please note that for successful testing, a device with at least 16GB of device memory is required


### Using Docker

#### Interactive

To run the benchmark interactively, use:

`sudo docker run --rm -it --device /dev/kfd --device /dev/dri --security-opt seccomp=unconfined rochpl.6.0 /bin/bash`

Once you are in the interactive session, the benchmark may be run using the command  `mpirun_rochpl`  with your specific options. For example:

`mpirun_rochpl -P 1 -Q 1 -N 45312`

#### Non-Interactive

To run the benchmark non-interactively, use the  `mpirun_rochpl`  command as part of the command line. For example:

`sudo docker run --rm --device /dev/kfd --device /dev/dri --security-opt seccomp=unconfined rochpl.6.0  mpirun_rochpl -P 1 -Q 1 -N 45312`

### Using Singularity

This section assumes that an up-to-date version of Singularity is installed on your system and properly configured for your system. Please consult with your system administrator or view official Singularity documentation.

Pull and convert the docker image to a singularity image format:

`singularity pull rochpl.sif docker://rochpl.6.0`

You can then use the information from the Running Application section to run a benchmark.

Launch a container:

`singularity run --pwd /tmp --writable-tmpfs rochpl.sif /bin/bash`

Then run the benchmark as desired. For example using a single GPU:

`mpirun_rochpl -P 1 -Q 1 -N 45312`

## Licensing Information
Your use of this RocHPL application (“Application”) is subject to the terms of the BSD-2 License ([https://opensource.org/licenses/BSD-2-Clause](https://opensource.org/licenses/BSD-2-Clause)) as set forth below. By accessing or using this Application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application. For the avoidance of doubt, this license supersedes any other agreement between AMD and you with respect to your access or use of the Application.

BSD 2 Clause

Copyright © 2023, Advanced Micro Devices, Inc. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The Application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|rocHPL|BSD 3-Clause|[HPL](https://icl.utk.edu/hpl/)<br />[rocHPL](https://github.com/ROCmSoftwarePlatform/rocHPL/)<br />[rocHPL License](https://github.com/ROCmSoftwarePlatform/rocHPL/blob/main/LICENSE)|
|BLIS|BSD 3-Clause|[BLIS License](https://github.com/amd/blis/blob/master/LICENSE)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.   

## Notices and Attribution
© 2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.  

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.  Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.    

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
