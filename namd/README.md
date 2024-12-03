# NAMD  

## Overview
[NAMD](www.ks.uiuc.edu/Research/namd) is a molecular dynamics package designed for simulating the movement of biomolecules over time. It is suited for large biomolecular systems, and it has been used to simulate systems with over 1 billion atoms, presenting stellar scalability on thousands of CPU cores and GPUs. NAMD’s inherent scalability has been awarded with two Gordon Bell prizes.

NAMD is distributed free of charge. User(s) of the NAMD container(s) are reminded to register on the [NAMD download site](https://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD) if they have not done so already.
 
## Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s)| Ubuntu 18.04 <br> Cento 8.3 | ROCm v4.5 compatibility |[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) | 

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Running NAMD
In order to assess performance of the container image, NAMD standard benchmark systems were made available in the `/examples` directory, with sizes ranging from 23 thousand up to a million atoms. If the user wants to collect figure of merit numbers (nanoseconds of simulated time per day) on a machine containing 64-cores and one AMD GPU, it is possible using the following processes for [NAMD 2](#namd-2) or [NAMD 3](#namd-3).

### NAMD 2
#### Docker Container

```
docker pull amdih/namd:2.15a2-20211101
```

#### Running NAMD 2
In order to assess performance of the container image, NAMD standard benchmark systems were made available in the `/examples` directory, with sizes ranging from 23 thousand up to a million atoms. If the user wants to collect figure of merit numbers (nanoseconds of simulated time per day) on a machine containing 64-cores and one AMD GPU, it is possible using the following process.

Begin by launching a container interactively:
```
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined  amdih/namd:2.15a2-20211101 /bin/bash
```

Then in the container navigate into the `/examples` directory and run the benchmarks:
```
cd /examples
/opt/namd/bin/namd2 jac/jac.namd +p64 +setcpuaffinity +devices 0 > jac.log
/opt/namd/bin/namd2 apoa1/apoa1.namd +p64 +setcpuaffinity +devices 0 > apoa1.log
/opt/namd/bin/namd2 f1atpase/f1atpase.namd +p64 +setcpuaffinity +devices 0 > f1atpase.log
/opt/namd/bin/namd2 stmv/stmv.namd +p64 +setcpuaffinity +devices 0 > stmv.log
```

The following commands generate NAMD log files with timing information for each one of the benchmarks and averages that information using the `ns_per_day.py` Python utility, calculating the overall nanoseconds of simulated time per day on that run.

Benchmarking everything might take many minutes depending on how fast your computational resources are.
```
./ns_per_day.py jac.log
./ns_per_day.py apoa1.log
./ns_per_day.py f1atpase.log
./ns_per_day.py stmv.log
```

### NAMD 3
#### Pull Command

```
docker pull amdih/namd3:3.0a9
```
#### Running NAMD 3

Begin by launching a container interactively:
```
docker run --rm -it --ipc=host --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/namd3:3.0a9 /bin/bash
```

Then in the container navigate into the `/examples` directory and run the benchmarks:
```
cd /examples
namd3 jac/jac.namd +p1 +setcpuaffinity --CUDASOAintegrate on +devices 0 > jac.log
namd3 apoa1/apoa1.namd +p1 +setcpuaffinity --CUDASOAintegrate on +devices 0 > apoa1.log
namd3 f1atpase/f1atpase.namd +p1 +setcpuaffinity --CUDASOAintegrate on +devices 0 > f1atpase.log
namd3 stmv/stmv.namd +p1 +setcpuaffinity --CUDASOAintegrate on +devices 0 > stmv.log
```

The following commands generate NAMD log files with timing information for each one of the benchmarks and averages that information using the `ns_per_day.py` Python utility, calculating the overall nanoseconds of simulated time per day on that run.

Benchmarking everything might take many minutes depending on how fast your computational resources are.
```
./ns_per_day.py jac.log
./ns_per_day.py apoa1.log
./ns_per_day.py f1atpase.log
./ns_per_day.py stmv.log
```

For multiple-GPU simulations, NAMD 3.0 needs to run with exactly one CPU core per GPU. For a 4-GPU simulation, here’s how one would invoke NAMD 3.0 in GPU-resident mode.
``` 
cd /examples
namd3 stmv/stmv.namd +p4 +pemap 0-3 --CUDASOAintegrate on +devices 0,1,2,3 > stmv.log
``` 

Benchmarking everything might take many minutes depending on how fast your computational resources are.


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
|Charm++|Charm++/Converse|[Charm++](https://charmplusplus.org/)<br >[Charm++ License](https://github.com/UIUC-PPL/charm/tree/main?tab=License-1-ov-file#readme)|
|NAMD|MITx11|[NAMD](https://www.ks.uiuc.edu/Research/namd/) <br> [NAMD License](https://www.ks.uiuc.edu/Research/namd/license.html)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
