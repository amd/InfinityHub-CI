# MILC

## Overview
The MILC Code is a set of research codes developed by MIMD Lattice Computation (MILC) collaboration for doing simulations of four dimensional SU(3) lattice gauge theory on MIMD parallel machines scaling from single-processor workstations to HPC systems. The MILC Code is publicly available for research purposes. Publications of work done using this code or derivatives of this code should acknowledge this use. [Usage conditions](http://www.physics.utah.edu/~detar/milc/milcv7.html#Usage-conditions).



## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Build Recipes
- [Docker/Singularity Build](/milc/docker/)


## Running MILC Benchmarks
The latest MILC benchmark details can be found on [NERSC GitLab N10-benchmarks/lattice-gcd-workflow](https://gitlab.com/NERSC/N10-benchmarks/lattice-qcd-workflow).

There are 2 benchmarks within the repo, `generation` and `spectrum` and 4 size lattice that can be downloaded, based on the size of the system. 
|Size| GPUs/GCDs|input_file| File Size |
|---|---|---|---|
|`tiny`|4|input_4864|1.9GB x2|
|`small`|16|input_6496|6.8GB x2|
|`medium`|128|input_96192|46GB x2|
|`reference`|512|input_144288|231GB x2|
|`target`|1152|input_192384|730GB|


The benchmark input files for each size can be be found here:
```
.../lattice-qcd-workflow/benchmarks/$SIZE/$BENCHMARK/
```
The default location defined in the input files is:
```
.../lattice-qcd-workflow/benchmarks/$SIZE/$BENCHMARK/lattices
``` 
The input file can be updated, to where ever the lattices are.
Update the line in the input file `reload_parallel .../path/to/lattice/$LATTICE_FILE` 
To Download the lattices
```
.../lattice-qcd-workflow/lattices/wgetlattice.sh $SIZE
```
> `QUDA_RESOURCE_PATH` is where several tuning files will be generated on the first run. This can be stored anywhere with read/write permissions are available.  
> Within provided image recipe this has been set to `/tmp`.  
> The first run on each system/configuration can take up to 2-3x longer due to generating these tuning files. 
> These tuning files are used on all subsequent runs for that system. 
> It is recommended to run the provided MILC benchmark once, to generate these tuning files, before processing a workload.  

### Example
#### Generation
```
cd .../lattice-qcd-workflow/benchmarks/$SIZE/generation/ 

mpirun -n #GPUs  su3_rhmd_hisq $INPUT_FILE
```

#### Spectrum
```
cd .../lattice-qcd-workflow/benchmarks/$SIZE/spectrum/ 

mpirun -n #GPUs  ks_spectrum_hisq $INPUT_FILE
```




### Previous MILC Benchmarks
For running the previous NERSC MILC benchmark, please see the instructions for [Running the NERSC MILC Benchmarks](https://github.com/lattice/quda/wiki/Running-the-NERSC-MILC-Benchmarks). This benchmark has not been provided in the [MILC Docker](/milc/docker/). The full instructions are provided on github.  
To run these benchmarks within a container, use the `-v` for docker or `--bind` for singularity to mount the datasets into the container. 

#### Known Issues
Multi-GPU runs with MI100 GPUs using ROCm 5.x GPU driver, MILC benchmarks may freeze and not return with an exit code upon completion of the benchmark.

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
|MILC|MIT (Custom)|[MILC](http://physics.utah.edu/~detar/milc/)<br >[MILC License](https://github.com/milc-qcd/milc_qcd/blob/master/LICENSE)|
|QMP|Jefferson Science Associates LLC Copyright (Custom) |[QMP](https://github.com/usqcd-software/qmp)<br >[QMP License](https://github.com/usqcd-software/qmp/blob/master/LICENSE)|
|QIO|Jefferson Science Associates LLC Copyright (Custom) |[QIO](https://github.com/usqcd-software/qio)<br >[QIO License](https://github.com/usqcd-software/qio/blob/master/COPYING)|
|QUDA|MIT (Custom) |[QUDA](https://github.com/lattice/quda)<br >[QUDA License](https://github.com/lattice/quda/blob/develop/LICENSE)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
