# RELION

## Overview
RELION (REgularized LIkelihood OptimizatioN) implements an empirical Bayesian approach for analysis of electron cryo-microscopy (Cryo-EM). Specifically, RELION provides refinement methods of singular or multiple 3D reconstructions as well as 2D class averages. RELION is an important tool in the study of living cells.  

RELION is comprised of multiple steps that cover the entire single-particle analysis workflow. Steps include beam-induced motion-correction, CTF estimation, automated particle picking, particle extraction, 2D class averaging, 3D classification, and high-resolution refinement in 3D. RELION can process movies generated from direct-electron detectors,  apply final map sharpening, and perform local-resolution estimation. More information can be obtained from the [official documentation](https://relion.readthedocs.io/en/release-4.0/).

## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
|---- |---- |----------------- |------------ |------------------ | 
| X86_64 CPU(s) |[AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br>  AMD Instinct MI50 GPU(s)](https://rocm.docs.amd.com/en/docs-5.3.0/release/gpu_os_support.html#supported-distributions) | [Ubuntu <br> RHEL <br>  SLES  ](https://rocm.docs.amd.com/en/docs-5.3.0/release/gpu_os_support.html#supported-distributions) | [ROCm 5.3.0](https://rocm.docs.amd.com/en/docs-5.3.0/) | [Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Running RELION
Before launching the container, first grab the standard RELION benchmarks.
```
wget sftp://ftp.mrc-lmb.cam.ac.uk/pub/scheres/relion_benchmark.tar.gz
tar –xvf relion_benchmark.tar.gz
```
> This dataset is approximately 50 GB, it will take some time to download. 


### Pull Docker Image
```
docker pull amdih/relion:4.0
```

### Running with Docker

#### Docker Interactive 
```
docker run \
    -w /benchmark \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -v /path/to/relion_benchmark:/benchmark \
    -it amdih/relion:4.0 /bin/bash
```
#### Docker Single Command 
```
docker run \
    -w /benchmark \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -v /path/to/relion_benchmark:/benchmark \
    -it amdih/relion:4.0 <RELION Command>
```
### Running with Singularity

#### Pull Singularity
```
singularity pull relion.sif docker://amdih/relion:4.0
```

#### Singularity Interactive
```
singularity shell \
    --pwd /benchmark \
    --writable-tmpfs \
    --bind /path/to/relion_benchmark:/dataset:ro \
    relion.sif
```

#### Singularity Single Command
```
singularity run \
    --pwd /benchmark \
    --writable-tmpfs \
    --bind /path/to/relion_benchmark:/dataset:ro
    relion.sif <RELION Command>
```

### Running RELION Benchmark  
There is a convenient benchmark script included.  
This script is designed run RELION Plasmodium Ribosome (2D/3D) benchmarks on GPUs.

```
./run-benchmark --class <xy> -g <XY> -n <ZZ> -j <yy> -p <xx> -i <path-to-data> --iter <xyz> -o <path-to-output-dir>


       -h | --help      Prints the usage
       -d | --gpu-support Support for GPU offloading (defaults to HIP, or select CUDA)
       -g | --ngpus     Number of GPUs to be used (1/2/4/8, defaults to 1)
       -n | --ranks     Number of MPI ranks
       -j | --threads   Max. number of threads per proc
       -p | --pool      Max. number of jobs per thread
       -o | --output-dir Output directory
       -i | --data      Path to the dataset
            --class     Select benchmark type (options 2d|3d - case insensitive)
            --iter(s)   Specify the number of iterations to run for (default: 25)
            --continue  Continue the benchmark from a prev. iter# (e.g. --continue 15)

```

> **NOTE:**
> For a parallel run with multiple MPI ranks and GPUs, the leader MPI rank distributes work to the rest of the followers that are explicitly mapped to a given GPU device to offload work. Hence, the number of MPI ranks should be carefully selected such that # MPI ranks minus one is divisible by # GPUs, e.g.: if `--ngpus=4`, then `-n=5,9,13`, etc. However, the product of # MPI ranks and # threads must be less than or equal to the total # physical cores on the server. The `run-benchmark` script takes care of these settings and should return a warning/error if any of these conditions are violated.

#### Example Benchmarks
For both examples, replace `#` with number of GPUs. 
##### 2D
```
run-benchmark --class 2d -g # -n 33 -j 3 -p 10 --iters 25 -i /dataset
```

##### 3D
```
run-benchmark --class 3d -g # -n 17 -j 6 -p 10 --iters 25 -i /dataset
```

A full list configurations for RELION can be found in the [RELION documentation](https://relion.readthedocs.io/en/release-4.0/SPA_tutorial/index.html) or [benchmark wiki page](https://www3.mrc-lmb.cam.ac.uk/relion//index.php/Benchmarks_&_computer_hardware#Standard_benchmarks).


### Performance considerations

* Figure of Merit (FoM): Time elapsed in seconds to complete 25 iterations
* FOM bigger is better (y/N)?: No
* 2D benchmark on 1 GPU can take as much as 6+hrs and dividing the workload between multiple GPUs and MPI ranks provides speedup. However, one must pay careful attention to the combination of MPI ranks, threads per rank and pool of jobs per thread used for the benchmark run. To determine optimal parameter values, a parameter sweep must be performed to identify the best configuration, varying MPI ranks and threads per rank.
* A slightly older reference provides information on [MPI task distribution](https://hpc.nih.gov/apps/RELION/index.html#mpi) and [GPUs](https://hpc.nih.gov/apps/RELION/index.html#gpu) with RELION


### Known Issues / Errata
* RELION application typically needs a large local scratch disk space, ideally SSD or RamFS. The example presented needs at least 100 GB of scratch space for the benchmark data.
* If you see "memory allocator issue" error, please add the following argument into your Relion run command `--free_gpu_memory 30000`. 
* In some cases, when the problem size is too big or the available memory on the GPU card is not large enough, the amount of free GPU memory requested above will be ignored, and a WARNING message will be displayed as shown below. In such situations, by default a safer lower-limit of 30% of total GPU memory is marked free instead and the simulation continues utilizing 70% of the GPU memory. One can safely ignore these warnings, or can choose to modify the amount of free memory requested through the `--free_gpu_memory` to get rid of the warnings.    

  ```
  =============================
   Oversampling= 1 NrHiddenVariableSamplingPoints= 8601600
   OrientationalSampling= 2.8125 NrOrientations= 512
   TranslationalSampling= 1.34 NrTranslations= 84
  =============================
  WARNING: Ignoring required free GPU memory amount of 30600 MB, due to space insufficiency.
  WARNING: Ignoring required free GPU memory amount of 30600 MB, due to space insufficiency.
  ```

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
|RELION|GPL-2.0|[RELION](https://github.com/3dem/relion)<br >[RELION License](https://github.com/3dem/relion/blob/master/LICENSE)|



Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
