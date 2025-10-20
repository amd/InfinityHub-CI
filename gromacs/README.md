# GROMACS
## Overview
This AMD Container is based on the 2025 release of GROMACS modified by AMD. This container only supports up to an 8 GPU configuration.

GROMACS is a versatile package to perform molecular dynamics, i.e. simulate the Newtonian equations of motion for systems with hundreds to millions of particles. It is primarily designed for biochemical molecules like proteins, lipids and nucleic acids that have a lot of complicated bonded interactions, but since GROMACS is extremely fast at calculating the nonbonded interactions (that usually dominate simulations) many groups are also using it for research on non-biological systems, e.g. polymers.
For more information about GROMACS, visit [gromacs.org](https://www.gromacs.org).

For more information on the ROCm™ open software platform and access to an active community discussion on installing, configuring, and using ROCm, please visit the ROCm web pages at www.AMD.com/ROCm and [ROCm Community Forum](https://community.amd.com/t5/rocm/ct-p/amd-rocm)
>Notes:
>- This recipe is based on a fork of the GROMACS project written for AMD GPUs - it is not an official release by the GROMACS team
>- The specific code is currently in the process of being upstreamed, with progress trackable here: https://gitlab.com/gromacs/gromacs/-/issues/4947
>- The source of the GROMACS fork is publicly available here: https://gitlab.com/gromacs/gromacs/-/tree/4947-hip-feature-enablement?ref_type=heads
>- This code base is not maintained or supported by the GROMACS team directly during the upstreaming process

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements)  
 
## Build Recipes
- [Bare Metal Build](/gromacs/baremetal/)
- [Docker/Singularity Build](/gromacs/docker/)

## Running Gromacs Benchmarks
Three example benchmarks have been provided in this repository:
- [ADH DODEC](/gromacs/docker/benchmark/adh_dodec/) 
    - [Threaded MPI Examples](#adh_dodec) 
    - [OpenMPI Examples](#adh-dodec-openmpi)
- [Cellulose NVE](/gromacs/docker/benchmark/cellulose_nve/)  
    - [Threaded MPI Examples](#cellulose_nve) 
    - [OpenMPI Examples](#cellulose-nve-openmpi)
- [STMV](/gromacs/docker/benchmark/stmv/) 
    - [Threaded MPI Examples](#stmv) 
    - [OpenMPI Examples](#stmv-openmpi)

>**Performance Tuning for Threaded MPI**  
> Optimal performance for each benchmark and GPU/GCD configuration can be tuned by:
> - MPI ranks/threads (`-ntmpi`)
> - OpenMP threads (`-ntomp`)
> - GPUs (`-gpu_id`)
> - Neighbor list update frequency (`-nstlist`)
> - More performance options found at Gromacs' documentation: "[Getting good performance from **mdrun**](https://manual.gromacs.org/documentation/current/user-guide/mdrun-performance.html)"
> - The offloading of bonds to GPUs (`-bonded gpu`) is not always recommended for optimal performance.


### Examples With Threaded MPI 
---
<details>
<summary> ADH DODEC Benchmark Instructions </summary>

#### ADH DODEC
Extract the binary system topology, parameter, coordinates, and velocity file. 

```
cd .benchmarks/adh_dodec
tar -xvf adh_dodec.tar.gz
```

<details> 
<summary>1 GPU/GCD</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 1 \
            -ntomp 64 \
            -noconfout \
            -nb gpu \
            -bonded cpu \
            -pme gpu \
            -v \
            -nstlist 100 \
            -gpu_id 0 \
            -s topol.tpr
```
</details>
<details> 
<summary>2 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 2 \
            -ntomp 32 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 200 \
            -gpu_id 01 \
            -s topol.tpr
```
</details>
<details> 
<summary>4 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 4 \
            -ntomp 16 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 200 \
            -gpu_id 0123 \
            -s topol.tpr
```
</details>
<details> 
<summary>8 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 8 \
            -ntomp 8 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 150 \
            -gpu_id 01234567 \
            -s topol.tpr
```
</details> 
</details>

---

<details>
<summary>CELLULOSE NVE Benchmark Instructions</summary>

#### CELLULOSE NVE
Extract the binary system topology, parameter, coordinates, and velocity file.

```
cd .benchmarks/cellulose_nve
tar -xvf cellulose_nve.tar.gz
```
<details> 
<summary>1 GPU/GCD</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 1 \
            -ntomp 64 \
            -noconfout \
            -nb gpu \
            -bonded cpu \
            -pme gpu \
            -v \
            -nstlist 100 \
            -gpu_id 0 \
            -s topol.tpr
```
</details>
<details> 
<summary>2 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 4 \
            -ntomp 16 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v -nstlist 200 \
            -gpu_id 01 \
            -s topol.tpr
```
</details>
<details> 
<summary>4 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 4 \
            -ntomp 16 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 200 \
            -gpu_id 0123 \
            -s topol.tpr
```
</details>
<details> 
<summary>8 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 8 \
            -ntomp 8 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 200 \
            -gpu_id 01234567 \
            -s topol.tpr
```
</details>
</details>

---  

<details> 
<summary>STMV Benchmark Instructions</summary>

#### STMV
Extract the binary system topology, parameter, coordinates, and velocity file. 

```
cd .benchmarks/stmv
tar -xvf stmv.tar.gz
```
<details> 
<summary>1 GPU/GCD</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 1 \
            -ntomp 64 \
            -noconfout \
            -nb gpu \
            -bonded cpu \
            -pme gpu \
            -v \
            -nstlist 200 \
            -gpu_id 0 \
            -s topol.tpr
```
</details>
<details> 
<summary>2 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 8 \
            -ntomp 8 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 200 \
            -gpu_id 01 \
            -s topol.tpr
```
</details>
<details> 
<summary>4 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 8 \
            -ntomp 8 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 400 \
            -gpu_id 0123 \
            -s topol.tpr
```
</details>
<details> 
<summary>8 GPUs/GCDs</summary>

```
gmx mdrun -pin on \
            -nsteps 100000 \
            -resetstep 90000 \
            -ntmpi 8 \
            -ntomp 8 \
            -noconfout \
            -nb gpu \
            -bonded gpu \
            -pme gpu \
            -npme 1 \
            -v \
            -nstlist 400 \
            -gpu_id 01234567 \
            -s topol.tpr
```
</details>
</details>

---
### Examples With OpenMPI 
---
<details>
<summary> ADH DODEC OpenMPI Benchmark Instructions </summary>

#### ADH DODEC OpenMPI
Extract the binary system topology, parameter, coordinates, and velocity file. 

```
cd .benchmarks/adh_dodec
tar -xvf adh_dodec.tar.gz
```

<details> 
<summary>1 GPU/GCD</summary>

```
mpirun -np 1 \
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 64 \
		-noconfout \
		-nb gpu \
		-bonded cpu \
		-pme gpu \
		-v \
		-nstlist 100 \
		-gpu_id 0 \
		-s topol.tpr
```
</details>
<details> 
<summary>2 GPUs/GCDs</summary>

```
mpirun -np 2 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 32 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 200 \
		-gpu_id 01 \
		-s topol.tpr
```
</details>
<details> 
<summary>4 GPUs/GCDs</summary>

```
mpirun -np 4 \n	\ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 16 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 200 \
		-gpu_id 0123 \
		-s topol.tpr
```
</details>
<details> 
<summary>8 GPUs/GCDs</summary>

```
mpirun -np 8 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 8 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 150 \
		-gpu_id 01234567 \
		-s topol.tpr
```
</details> 
</details>

---

<details>
<summary>CELLULOSE NVE OpenMPI Benchmark Instructions </summary>

#### CELLULOSE NVE OpenMPI
Extract the binary system topology, parameter, coordinates, and velocity file.

```
cd .benchmarks/cellulose_nve
tar -xvf cellulose_nve.tar.gz
```
<details> 
<summary>1 GPU/GCD</summary>

```
mpirun -np 1 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 64 \
		-noconfout \
		-nb gpu \
		-bonded cpu \
		-pme gpu \
		-v \
		-nstlist 100 \
		-gpu_id 0 \
		-s topol.tpr
```
</details>
<details> 
<summary>2 GPUs/GCDs</summary>

```
mpirun -np 2 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 16 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v -nstlist 200 \
		-gpu_id 01 \
		-s topol.tpr
```
</details>
<details> 
<summary>4 GPUs/GCDs</summary>

```
mpirun -np 4 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 16 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 200 \
		-gpu_id 0123 \
		-s topol.tpr
```
</details>
<details> 
<summary>8 GPUs/GCDs</summary>

```
mpirun -np 8 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 8 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 200 \
		-gpu_id 01234567 \
		-s topol.tpr
```
</details>
</details>

---  

<details> 
<summary>STMV OpenMPI Benchmark Instructions </summary>

## STMV OpenMPI
Extract the binary system topology, parameter, coordinates, and velocity file. 

```
cd .benchmarks/stmv
tar -xvf stmv.tar.gz
```
<details> 
<summary>1 GPU/GCD</summary>

```
mpirun -np 1 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 64 \
		-noconfout \
		-nb gpu \
		-bonded cpu \
		-pme gpu \
		-v \
		-nstlist 200 \
		-gpu_id 0 \
		-s topol.tpr
```
</details>
<details> 
<summary>2 GPUs/GCDs</summary>

```
mpirun -np 2 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 8 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 200 \
		-gpu_id 01 \
		-s topol.tpr
```
</details>
<details> 
<summary>4 GPUs/GCDs</summary>

```
mpirun -np 4 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 8 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 400 \
		-gpu_id 0123 \
		-s topol.tpr
```
</details>
<details> 
<summary>8 GPUs/GCDs</summary>

```
mpirun -np 8 \ 
	gmx_mpi mdrun -pin on \
		-nsteps 100000 \
		-resetstep 90000 \
		-ntomp 8 \
		-noconfout \
		-nb gpu \
		-bonded gpu \
		-pme gpu \
		-npme 1 \
		-v \
		-nstlist 400 \
		-gpu_id 01234567 \
		-s topol.tpr
```
</details>
</details>

--- 
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
|Gromacs|LGPL 2.1|[Gromacs](https://www.gromacs.org/)<br /> [Gromacs License](https://github.com/gromacs/gromacs/blob/main/COPYING)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

The GROMACS source code and selected set of binary packages are available here: www.gromacs.org. GROMACS is Free Software, available under the GNU Lesser General Public License (LGPL), version 2.1. You can redistribute it and/or modify it under the terms of the LGPL as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale. AMD, the AMD Arrow logo and combinations thereof are trademarks of Advanced Micro Devices, Inc. Other product names used in this publication are for identification purposes only and may be trademarks of their respective companies.

## Notices and Attribution
© 2021-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
