# Grid

## Overview
Grid is a library for lattice QCD calculations that employs a high-level data parallel approach while using a number of techniques to target multiple types of parallelism. The library currently supports MPI, OpenMP and short vector parallelism. The SIMD instructions sets covered include SSE, AVX, AVX2, FMA4, IMCI and AVX512. Recent releases expanded this support to include GPU offloading. The code requires at least one AMD GPU to run. 

The source code is available on [github](https://github.com/paboyle/Grid). 

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Build Recipes
- [Docker/Singularity Build](/grid/docker/)


## Running Grid Benchmarks
These examples are using the Container built using  [Grid Docker Build](/grid/docker/). 

Grid has many examples within the project `/opt/grid/bin/` directory. 

You can run the examples using the command syntax below, where   
`<gpus>` is the number of GPUs to use   
`./benchmark/gpu_bind.sh` defines the CPU to GPU NUMA mapping  
 `<benchmark-to-run>` is the name of the benchmark to run  
 `<threads>` is the number of threads to use  
  `<i>` is the MPI configuration   

```
mpirun -np <gpus> ./benchmark/gpu_bind.sh <benchmark-to-run>  \
    --accelerator-threads <threads> --mpi <i> --shm 2048
```
The  `./benchmark/gpu_bind.sh` command may need to be updated for your specific CPU / GPU combination.  Use the `lscpu` command, to determine your NUMA configuration, and map the values back into the gpu_bind.sh command.

A combination of values for the MPI configuration, number of threads, gpus and other input parameters should be tested to achieve the highest throughput for your specific system.

### Examples 

* 1 GPU using Benchmark_ITT  
```
mpirun -np 1 /benchmark/gpu_bind.sh Benchmark_ITT --accelerator-threads 1 --mpi 1.1.1.1 --shm 2048
```

* 4 GPUs using Benchmark_ITT  
```
mpirun -np 4 /benchmark/gpu_bind.sh Benchmark_ITT --accelerator-threads 4 --mpi 4.1.1.1 --shm 2048
```

* 8 GPUs using Benchmark_ITT  
```
mpirun -np 8 /benchmark/gpu_bind.sh Benchmark_ITT --accelerator-threads 8 --mpi 8.1.1.1 --shm 2048
```

Each MPI rank will bind to a particular unique GPU (1 rank per device) and strong-scale the problem accordingly. 


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
|Grid|GPL V2|[Grid](https://github.com/paboyle/Grid)<br >[Grid License](https://github.com/paboyle/Grid/blob/develop/LICENSE)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
