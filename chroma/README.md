# CHROMA

## Overview
The Chroma package supports data-parallel programming constructs for lattice field theory and in particular lattice QCD. It uses the SciDAC QDP++ data-parallel programming (in C++) that presents a single high-level code image to the user, but can generate highly optimized code for many architectural systems including single node workstations, multi and many-core nodes, clusters of nodes via QMP, and classic vector computers.


## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
|---- |---- |----------------- |------------ |------------------ | 
| X86_64 CPU(s) |[AMD Instinct MI300A/X APU/GPU(s) <br> AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s)](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.1.1/reference/system-requirements.html#supported-gpus) | [Ubuntu <br> RHEL <br>  SLES  <br> Oracel Linux](https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.1.1/reference/system-requirements.html#supported-operating-systems) | [ROCm 6.1.x](https://rocm.docs.amd.com/en/docs-6.1.1/) | [Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Build Recipes
- [Docker/Singularity Build](/chroma/docker/)


## Running Chroma Benchmarks
The benchmark used for Chroma can be downloaded from [NGC](https://catalog.ngc.nvidia.com/orgs/hpc/containers/chroma), look for szscl_bench.zip.
This has already been provided in the [Chroma Docker Build](/chroma/docker/Dockerfile#L320).

Once Chroma has been installed with all of the components,  and the benchmark files have been extracted to a working directory there are a couple environment variables that are recommended to pass in or set on the system. 

```
QUDA_ENABLE_P2P=0
QUDA_ENABLE_GDR=0
QUDA_RESOURCE_PATH=/tmp/
```

`QUDA_RESOURCE_PATH` is where several tuning files will be generated on the first run. This can be stored anywhere with read/write permissions are available. They are used on all subsequent runs for that system. 
The first run on each system/configuration can take up to 2-3x longer due to generating these tuning files. It is recommended to run the provided Chroma benchmark once, to generate these tuning files, before processing a workload. 

### Example:
The `#` should be replaced by the number of GPUs to be used. 
`QUDA_RESOUCE_PATH` should be provided similar to examples below. If not set as an environment variable or at run time, it will create the tuning files in the directory the command is executed from.  

```
QUDA_RESOURCE_PATH=/path/to/tuning mpirun -n # chroma -i ./test.ini.xml -geom 1 1 1 # -ptxdb ./qdpdb -gpudirect
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
|Chroma|Jefferson Science Associates LLC Copyright (Custom)|[Chroma](https://github.com/JeffersonLab/chroma/)<br >[Chroma License](https://github.com/JeffersonLab/chroma/blob/master/LICENSE)|
|QMP|Jefferson Science Associates LLC Copyright (Custom) |[QMP](https://github.com/usqcd-software/qmp)<br >[QMP License](https://github.com/usqcd-software/qmp/blob/master/LICENSE)|
|QIO|Jefferson Science Associates LLC Copyright (Custom) |[QIO](https://github.com/usqcd-software/qio)<br >[QIO License](https://github.com/usqcd-software/qio/blob/master/COPYING)|
|QDPXX|Jefferson Science Associates LLC Copyright (Custom) |[QDPXX](https://github.com/usqcd-software/qdpxx)<br >[QDPXX License](https://github.com/usqcd-software/qdpxx/blob/master/COPYING)|
|QUDA|MIT (Custom)/ |[QUDA](https://github.com/lattice/quda)<br >[QUDA License](https://github.com/lattice/quda/blob/develop/LICENSE)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
