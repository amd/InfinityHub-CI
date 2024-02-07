# Trilinos

## Overview
Trilinos is a portable toolkit for scientific computing developed at Sandia National Laboratory. Trilinos is built on top of the Kokkos portability layer, which means it has support for all manner of architectures using a MPI+X methodology where MPI handles communication between distributed memory spaces, and local compute can be handled using a variety of CPU/GPU parallelization APIs such as OpenMP, CUDA, and HIP, as well as experimental backends including HPX and SYCL, all of which is hidden under the Kokkos abstraction layer.

## Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) | Ubuntu 20.04 <br> RHEL8 | ROCm v5.x compatibility|[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)


## Running Trilinos
Trilinos natively supports Serial, OpenMP, CUDA (NVIDIA), and HIP (AMD) layers for CPUs and associated accelerators. This version of Trilinos is based on a build of the Trilinos master branch from 5/25/2022 marked v13.5. To run the benchmark within this container, a supported AMD GPU must be available. To build against the Trilinos installed in this container, a valid GPU is not required, however it will be required to run the resulting binary. The server must also have a Docker Engine installed to run the container.  

### Krylov Benchmark
The benchmark provided in this container is an algebraic multigrid (AMG) preconditioned conjugant gradient (CG) solve applied to a 27 point structured finite-difference stencil. By default it operates on a 256&times;256&times;256 grid of points for 10 CG solver iterations with a Chebyshev smoother. The benchmark is designed to rebuild and solve the same system 10 times and reports the fastest times for preconditioner setup and CG solve. The preconditioner setup per iteration is designed to reuse symbolic data (i.e. the matrix sparsity pattern never changes), but recomputes the the preconditioner's numeric data each iteration.


> **Notes**  
> - The environment variable `HIP_VISIBLE_DEVICES` must be set for the number of GPUs for the intended run.   
> Replace `<SetDevices>` with format `0,1,2,3,4,5,6,7` using the number of GPUs on the execution node.  
> - The benchmark can be found in the `/benchmark` directory, and is not included as a component of Trilinos itself.
> The benchmark uses the `benchmark_krylov.exe` executable, which is called by the `run_benchmark` script found in the same directory.


### Docker Container
```
docker pull amdih/trilinos:1.7
```

### Running with Docker

#### Docker Interactive 
```
docker run \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --cap-add CAP_SYS_PTRACE \
    --shm-size=8g \
    -e HIP_VISIBLE_DEVICES=<SetDevices> \
    -it amdih/trilinos:1.7 /bin/bash
```
#### Docker Single Command 
```
docker run \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --cap-add CAP_SYS_PTRACE \
    --shm-size=8g \
    -e HIP_VISIBLE_DEVICES=<SetDevices> \
    amdih/trilinos:1.7 <Trilinos Command>
```
### Running with Singularity

#### Pull Singularity
```
singularity pull trilinos.sif docker://amdih/trilinos:1.7
```

#### Singularity Interactive
```
singularity shell \
    --env HIP_VISIBLE_DEVICES=<SetDevices> \
    --pwd /benchmark \
    --writable-tmpfs \
    Trilinos.sif
```

#### Singularity Single Command
```
singularity run \
    --env HIP_VISIBLE_DEVICES=<SetDevices> \
    --pwd /benchmark \
    --writable-tmpfs \
    Trilinos.sif <Trilinos Command>
```

### Running Trilinos Benchmark
The following are the `<Trilinos Commands>` that will run the benchmark provided.  
**1 GPU**
```
mpirun -n 1 /benchmark/run_benchmark --mx=1 --my=1 --mz=1 --kokkos-num-devices=1
```

**2 GPUs**
```
mpirun -n 2 /benchmark/run_benchmark --mx=2 --my=1 --mz=1 --kokkos-num-devices=2
```

**4 GPUs**
```
mpirun -n 4 /benchmark/run_benchmark --mx=2 --my=2 --mz=1 --kokkos-num-devices=4
```

**8 GPUs**
```
mpirun -n 8 /benchmark/run_benchmark --mx=2 --my=2 --mz=2 --kokkos-num-devices=8
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
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/release/licensing.html)|
|Trilinos|BSD 3-Clause, LGPL|[Trilinos](https://github.com/trilinos/Trilinos)<br >[Trilinos License](https://trilinos.github.io/license.html)|



Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
