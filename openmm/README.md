# OpenMM
OpenMM is a high performance toolkit for molecular simulation.
| Publisher | Built By | Multi-GPU Support |
| --------- | -------- | ----------------- |
| AMD       | AMD      | Yes               |

## Overview
Use OpenMM as a library, or as an application. We include extensive language bindings for Python, C, C++, and even Fortran. The code is open source and actively maintained on GitHub, licensed under MIT and LGPL. Part of the Omnia suite of tools for predictive biomolecular simulation.
For more information about OpenMM, visit
* http://openmm.org/


## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
|---- |---- |----------------- |------------ |------------------ | 
| X86_64 CPU(s) |[AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br>  AMD Instinct MI50 GPU(s)](https://rocm.docs.amd.com/en/docs-5.7.0/release/gpu_os_support.html#supported-distributions) | [Ubuntu <br> RHEL <br>  SLES ](https://rocm.docs.amd.com/en/docs-5.7.0/release/gpu_os_support.html#supported-distributions) | [ROCm 5.7.0](https://rocm.docs.amd.com/en/docs-5.7.0/) | [Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Building Recipes
[Docker/Singularity Build](/openmm/docker/)
## Running OpenMM Benchmarks
Within the [OpenMM Repo](https://github.com/openmm/openmm.git) there are many examples provided:
`gbsa`, `rf`, `pme`, `amoebagk`, `amoebapme`, `apoa1rf`, `apoa1pme`, `apoa1ljpme`, `amber20-dhfr`.  

Each example can be run at `single`, `double`, or `mixed` precision. 

From the directory `<path/to>/openmm/examples/` these benchmark examples can be executed by the following, by substituting `$BENCHMARK_NAME` and `$PRECISION` for the desired combination. 
```
python3 benchmark.py --platform HIP --test $BENCHMARK_NAME --precision $PRECISION
```

To execute all of these benchmarks execute by creating a simple bash script with the following
```bash
benchmarks=(gbsa rf pme amoebagk amoebapme apoa1rf apoa1pme apoa1ljpme amber20-dhfr)
precisions=(single mixed double)
for benchmark in "${benchmarks[@]}"; do
    for precision in "${precisions[@]}"; do
        python3 benchmark.py --platform HIP --test $benchmark --precision $precision
    done
done
```

>NOTE: 
> The following message will be returned: `/bin/sh: 1: nvidia-smi: not found.` When running the benchmarks using `benchmark.py`, the benchmark script attempts to run `nvidia-smi` and will fail since this tool is not part of the ROCm runtime supporting AMD Instinct GPUs.  The output will include `nvidia-smi: not found` messages. This message can safely be ignored and there is no effect on the benchmark results.

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any sub-component in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|OpenMM|MIT/GPL & LGPL v3.0|[OpenMM](https://openmm.org/)<br />[OpenMM License](https://github.com/openmm/openmm/tree/master/docs-source/licenses)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
