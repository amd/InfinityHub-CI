# BabelStream 

## Overview
BabelStream, formerly known as GPU-STREAM, is a synthetic GPU benchmark based on the original [STREAM](https://www.cs.virginia.edu/stream/) benchmark for CPUs. It is maintained by the [High-Performance Computing Group](http://uob-hpc.github.io/) at the University of Bristol. The official repository can be found here: https://github.com/UoB-HPC/BabelStream.

In version 4.0, BabelStream implements the four kernels from the original CPU STREAM benchmark (Copy, Mul, Add, and Triad), along with dot-product and "n-stream" kernels
from the [Parallel Research Kernels (PRK)](https://github.com/ParRes/Kernels) repository.

Key differences from STREAM and other GPU memory bandwidth benchmarks are that:

* PCIe transfer time is not included in measurements
* the arrays are allocated on the heap
* the problem size is unknown at compile time
* wider platform and programming model support

More information about BabelStream can be found by visiting the following references:

* [Evaluating attainable memory bandwidth of parallel programming models via BabelStream](https://dl.acm.org/doi/abs/10.5555/3292750.3292751)
* [GPU-STREAM v2.0: Benchmarking the achievable memory bandwidth of many-core processors across diverse parallel programming models](https://research-information.bris.ac.uk/en/publications/gpu-stream-v20-benchmarking-the-achievable-memory-bandwidth-of-ma)


## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
|---- |---- |----------------- |------------ |------------------ | 
| X86_64 CPU(s) |[AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br>  AMD Instinct MI50 GPU(s)](https://rocm.docs.amd.com/en/docs-5.3.0/release/gpu_os_support.html#supported-distributions) | [Ubuntu <br> RHEL <br>  SLES  ](https://rocm.docs.amd.com/en/docs-5.3.0/release/gpu_os_support.html#supported-distributions) | [ROCm 5.3.0](https://rocm.docs.amd.com/en/docs-5.3.0/) | [Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |


For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Running BabelStream Container
### Download Container
```
docker pull amdih/babelstream:4.amd0
```

### Docker
To run the container interactively use the following command, substituting the latest image tag from the [Download Container](#download-container) section.

#### Docker Interactive
```
docker run --rm --ipc=host --device=/dev/kfd --device=/dev/dri \
           --security-opt seccomp=unconfined \
           -it amdih/babelstream:4.amd0 bash
```
and run either the executable `hip-stream` or the helper script `run_babelstream.sh`. For non-interactive runs, simply replace `bash` with the desired run command. For example:

#### Docker Single Command
```
docker run --rm --ipc=host --device=/dev/kfd --device=/dev/dri \
           --security-opt seccomp=unconfined amdih/babelstream:4.amd0 <BabelStream command>
```

##### Saving results to host
The script `run_babelstream.sh` is able to generate `.csv` files containing the benchmark results.
To extract the results and have them available on your local machine, one simply needs
to mount a local directory when instantiating the container using `-v`:

For example, if we want to mount the local working directory `$(pwd)` to save data into, simply run:


```
docker run --rm --ipc=host -v $(pwd):/data \
           --device=/dev/kfd --device=/dev/dri \
           -it amdih/babelstream:4.amd0  bash
```

Here, the `-v` flag mounts the local working directory on the host machine `pwd` as a new
directory inside the container named `/data`. After generating output
(see the section "Benchmark runscript" for details), the files can be made available on the
host machine by simply running (inside the container): 
```
cp *.csv /data
```

### Singularity
Download and save the Singularity image locally, substituting the latest image tag from the [Download Container](#download-container) section.

#### Build Singularity Sif file
```
singularity pull babelstream.sif docker://amdih/babelstream:4.amd0
```

#### Singularity Interactive  
```
singularity shell --writable-tmpfs --no-home --pwd /opt/babelstream/build/ babelstream.sif
```

#### Singularity Single Command 
Using Singularity is similar to launching a Docker run; however, unlike Docker, the Singularity container does not land in the path where the executable resides, so  `--pwd /opt/babelstream/build/` must be provided for single command execution. 
```
singularity exec --writable-tmpfs --no-home --pwd /opt/babelstream/build/ babelstream.sif <BabelStream Command>
```

### BabelStream Commands

#### Running Hip-Stream

There are two ways to run BabelStream within the container. One is to use the compiled executable `hip-stream` directly, which can be run with the following arguments:

```
Usage: ./hip-stream [OPTIONS]

Options:
  -h  --help               Print the message
      --list               List available devices
      --device     INDEX   Select device at INDEX
  -s  --arraysize  SIZE    Use SIZE elements in the array
  -n  --numtimes   NUM     Run the test NUM times (NUM >= 2)
      --float              Use floats (rather than doubles)
      --triad-only         Only run triad
      --nstream-only       Only run nstream
      --csv                Output as csv table
      --mibibytes          Use MiB=2^20 for bandwidth calculation (default MB=10^6)
```

Running the executable without specifying either `--triad-only` or `--nstream-only` will run five kernels: Copy, Mul, Add, Triad, and Dot. It is important to note that the benchmark requires an array size that is divisible by 1024.

When running this benchmark as intended, arrays need to be suitably large such that data is streamed directly from device high bandwidth memory (HBM). On MI-100/200 devices, the following should more than sufficient:

```
./hip-stream -s $((2**28))
```

#### Running BabelStream Benchmark

Once the container is active, a bash script, `run_babelstream.sh`, is provided that will run the BabelStream benchmark on one or multiple GPUs. The container comes with an OpenMPI build for running *simultaneous* instances of BabelStream on multiple devices.

The script can be running in the following format:
```
mpirun -np <number of GCDs> ./run_babelstream.sh -n <number of iterations> -s <arraysize per rank>  [additional arguments]
```

A complete list of BabelStream options can be viewed by running `./run_babelstream.sh -h`:
```
***********************************************************************************************
BabelStream run script usage:
mpirun -np <num-of-gcds> ./run_babelstream.sh [-h ] [-w ] [-d # -s # -n # -p <precision> -o filename]
***********************************************************************************************

    This script allows you to build and run BabelStream. Users should provide inputs from the list below: 

    -w                        Write output files recording the BabelStream results.

    -o filename               Output filename for results collection. If not specified, results will be written to 'results_gcd#.csv'.

    -d #                      The device index (e.g. GCD 0, 1, ...). If not specified, the local MPI rank will be selected.
                                  NOTE: If you are specifying a certain GCD to run the benchmark on, do not run this script with MPI.

    -s #                      Specify the array size for the benchmark. If not specified, a default value of 268435456 is used.

    -n #                      Specify the number of iterations for the benchmark. If not specified, each kernel is run 100 times.

    -p < single | double >    Specify the precision for the benchmark. If not specified, double precision is used.
```
The run script wraps most of the options for the BabelStream executable, and so many of the same arguments (e.g. array size, number of iterations, precision) can be specified using the bash script. The bash script also supports MPI invocations, which will run simultaneous instances of BabelStream, one for each MPI rank.

As an example, the following command will run BabelStream on 4 MI250 AMD Instinct GPUs (8 total GCDs), where each BabelStream instance uses an array size of 268435456 elements and runs all kernels for a total of 50 iterations:
```
mpirun -np 8 ./run_babelstream.sh -s 268435456 -n 50
```
All output is funneled to `stdout`, therefore it may be useful to save the results for each GCD. This can be done by specifying the `-w` flag for writing output and (optionally) a filename via `-o`:
```
mpirun -np 8 ./run_babelstream.sh -s 268435456 -n 50 -w -o results
```
The command above will save the BabelStream benchmark results (for all 8 GCDs) to csv files enumerated by the MPI rank / device index, for example: `results_gcd#.csv`.

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|BabelStream|Custom|[BabelStream](https://github.com/UoB-HPC/BabelStream)<br >[BabelStream License](https://github.com/UoB-HPC/BabelStream?tab=License-1-ov-file#readme)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
