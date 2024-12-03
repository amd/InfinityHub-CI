# NWChem

## Overview
NWChem is a chemistry application designed to handle a wide variety of scientific problems and simulation modes.  
It aims to provide its users with computational chemistry tools that are scalable both in their ability to treat large scientific computational chemistry problems efficiently, and in their use of available parallel computing resources from high-performance parallel supercomputers to conventional workstation clusters. 
## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
|---- |---- |----------------- |------------ |------------------ | 
| X86_64 CPU(s) |[AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br>  AMD Instinct MI50 GPU(s)](https://rocm.docs.amd.com/en/docs-5.3.0/release/gpu_os_support.html#supported-distributions) | [Ubuntu <br> RHEL <br>  SLES  ](https://rocm.docs.amd.com/en/docs-5.3.0/release/gpu_os_support.html#supported-distributions) | [ROCm 5.3.0](https://rocm.docs.amd.com/en/docs-5.3.0/) | [Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |


For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Running NWChem

### Pull Command
```
docker pull amdih/nwchem:7.0.2.amd1
```

### Docker 

#### Interactive 
```
docker run --rm -it \
    --device /dev/dri \
    --device /dev/kfd \
    --security-opt seccomp=unconfined \
    -w /tmp \
    amdih/nwchem:7.0.2.amd1 /bin/bash
```

#### Single Command
```
docker run --rm -it \
    --device /dev/dri \ 
    --device /dev/kfd \
    --security-opt seccomp=unconfined \
    -w /tmp \
    amdih/nwchem:7.0.2.amd1 <NWChem Command>
```

### Singularity

#### Build Singularity
```
singularity pull nwchem.sif docker://amdih/nwchem:7.0.2.amd1
```

#### Interactive 
```
singularity shell --no-home --writable-tmpfs ./nwchem.sif
```
#### Single Command
```
singularity run --no-home --writable-tmpfs ./nwchem.sif <NWChem Command>
```

### Running  Benchmark
There are 3 "water" benchmarks of NWChem i.e. **w3**, **w5** and **w7**.  
These benchmarks can be run with the `run-benchmark` script bundled in the `/opt/nwchem/` folder.

**Water w3**
```
run-benchmark w3 --ngpus #
```
**Water w5**
```
run-benchmark w5 --ngpus #
```
**Water w7**
```
run-benchmark w7 --ngpus #
```
> Replace the # with the number of GPUs to be used. 

To run any of the examples, use the following format: 
``` 
OMP_NUM_THREADS=8 mpirun --report-bindings -np 1 nwchem /opt/nwchem/gpu/water/w3/w3_1gpu.nw
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
|NWChem|ECL-2.0|[NWChem](https://www.nwchem-sw.org/)<br >[NWChem License](https://github.com/nwchemgit/nwchem?tab=License-1-ov-file#readme)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
