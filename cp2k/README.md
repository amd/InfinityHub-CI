# CP2K

## Overview
CP2K is a quantum chemistry and solid state physics software package that can perform atomistic simulations of solid state, liquid, molecular, periodic, material, crystal, and biological systems. CP2K provides a general framework for different modeling methods such as [DFT](http://en.wikipedia.org/wiki/Density_functional_theory) using the mixed [Gaussian and plane waves approaches GPW and GAPW](https://www.cp2k.org/quickstep#gpw). Supported theory levels include DFTB, LDA, GGA, MP2, RPA, semi-empirical methods (AM1, PM3, PM6, RM1, MNDO, …), and classical force fields (AMBER, CHARMM, …). CP2K can do simulations of molecular dynamics, metadynamics, Monte Carlo, Ehrenfest dynamics, vibrational analysis, core level spectroscopy, energy minimization, and transition state optimization using NEB or dimer method. Detailed overview of features may be found at the [CP2K site](https://www.cp2k.org/features).

CP2K is written in Fortran 2008 and can be run efficiently in parallel using a combination of multi-threading, MPI, and HIP/CUDA. The CP2K software package is [freely available](https://www.cp2k.org/download) under the GPL license at https://www.cp2k.org.

For more information about CP2K, see www.cp2k.org.

The latest CP2K review, as of **May 2020**, can be found at **[The Journal of Chemical Physics 10.1063/5.0007045](https://doi.org/10.1063/5.0007045).**

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 


## Build Recipes
- [Bare Metal build](/cp2k/baremetal/)
- [Docker/Singularity Build](/cp2k/docker/)

> **NOTE**
> The recipes provided here use a script within CP2K to install the all dependencies. This toolchain script does not support MI300. 

## Running CP2K Benchmarks

<details>
<summary>MI210/MI100 GPUs</summary>

### MI210/MI100 GPUs

The following command can be used to run the [H2O-DFT-LS (NREP2)](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp) benchmark with 8 GPUs:

```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=8 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-8GPU.txt
```

In the above example, the H2O-DFT-LS (NREP2) benchmark is run on a dual socket server with 8 MI210 GPUs and 128 physical cores. The job in this example is run with 16 MPI ranks and 8 OpenMP threads per rank with two processes sharing a GPU. The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust these parameters accordingly.

A grep for `"CP2K     "` in the output file `/tmp/H2O-DFT-LS-NREP2-8GPU.txt` will show the elapsed time for the run.

The following command can be used to run the [H2O-DFT-LS (NREP2)](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp) benchmark with 4 GPUs:
```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=4 \
    -x RANK_STRIDE=4 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-4GPU.txt
```
In the above example, the H2O-DFT-LS (NREP2) benchmark is run a dual socket server that has 8 MI210 GPUs and 128 physical cores, but uses only 64 physical cores of one socket and 4 MI210 GPUs. The job in this example is run with 16 MPI ranks and 4 OpenMP threads per rank with two processes sharing a GPU. The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. Setting `RANK_STRIDE` to 4 allows the processes and their threads to be spread out and pinned to physical cores on the socket. If your system has a different configuration, please adjust the parameters accordingly.

A grep for `"CP2K     "` in the output file `/tmp/H2O-DFT-LS-NREP2-4GPU.txt` will show the elapsed time for the run.

The following commands can be used to run the [32-H2O-RPA](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/) benchmark. There are two steps involved in this benchmark namely the `init` and `solver` stages. The init stage will use the [H2O-32-PBE-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-PBE-TZ.inp) input file and the solver stage will use the [H2O-32-RI-dRPA-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-RI-dRPA-TZ.inp) input file.

>Note:  
>For this benchmark it is necessary to run from the `/opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O` directory due to file dependencies between the two stages.

First run the init stage:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=1 \
    -x RANK_STRIDE=4 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 4 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i H2O-32-PBE-TZ.inp \
    -o /tmp/32-H2O-RPA-init-1GPU.txt
```

Next, run the solver stage:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=8 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i H2O-32-RI-dRPA-TZ.inp \
    -o /tmp/32-H2O-RPA-solver-8GPU.txt
```

In the above example, the two stages of the 32-H2O-RPA benchmark are run on a dual socket server with 8 MI210 GPUs and 128 physical cores. The init step is run with 4 MPI ranks and 4 OpenMP threads per rank on 1 GPU with all 4 ranks sharing the GPU. The solver step is run with 16 MPI ranks and 8 OpenMP threads per rank on 8 GPUs with two processes sharing a GPU. The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust the parameters accordingly.

A grep for `"CP2K     "` in the output files `/tmp/32-H2O-RPA-*.txt` will show the elapsed time for each run.

>Note:  
>The above-mentioned commands can also be run verbatim on a dual socket server with 8 MI100 GPUs and 128 physical CPU cores. If your system configuration is different, please adjust the parameters accordingly.

</details>
<details>
<summary>MI250/MI300 GPUs</summary>
### MI250/MI300 GPUs

An MI250 GPU contains two Graphics Compute Dies (GCDs) each of which is presented to the application
as a separate GPU device. When running with MI250 GPUs, the scripts that set up CPU and GPU affinities,
namely `set_cpu_affinity.sh` and `set_gpu_affinity.sh`, require 
`NUM_GPUS` to be set up with the number of GCDs we want to run with.
In this section, we show how to run CP2K benchmarks on 1 and 4 MI250 GPUs which would translate
to setting `NUM_GPUS` with 2 and 8 respectively.

All the examples provided in this section show benchmarks run on a dual socket server with 4 MI250 GPUs and 128 physical cores.

The following command can be used to run the [H2O-DFT-LS (NREP2)](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp) benchmark on 16 physical CPU cores and 1 MI250 GPU with 4 MPI ranks and 4 OpenMP threads per rank with two processes sharing each GCD:
```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=2 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 4 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-1GPU.txt
```

The following command can be used to run the H2O-DFT-LS (NREP2) benchmark on 64 physical cores and 4 MI250 GPUs with 16 MPI ranks and 4 OpenMP threads per rank with two processes sharing each GCD:
```
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i /opt/cp2k/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp \
    -o /tmp/H2O-DFT-LS-NREP2-4GPU.txt
```

The `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust these parameters accordingly.

A grep for `"CP2K     "` in the output file `/tmp/H2O-DFT-LS-NREP2-*.txt` will show the elapsed time for each run.

The following commands can be used to run the [32-H2O-RPA](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/) benchmark on MI250 GPUs. There are two steps involved in this benchmark namely the `init` and `solver` stages. The init stage will use the [H2O-32-PBE-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-PBE-TZ.inp) input file and the solver stage will use the [H2O-32-RI-dRPA-TZ.inp](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-RI-dRPA-TZ.inp) input file.

>Note:  
>For this benchmark it is necessary to run from the `/opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O` directory due to file dependencies between the two stages.*

First, the init step is run with 4 MPI ranks and 4 OpenMP threads per rank on 1 MI250 GPU (2 GCDs) with 2 ranks sharing each GCD:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=2 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 4 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i H2O-32-PBE-TZ.inp \
    -o /tmp/32-H2O-RPA-init-1GPU.txt
```

Next, the solver step may be run on 1 MI250 GPU with 8 MPI ranks and 2 OpenMP threads per rank with 4 processes sharing each GCD:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=2 \
    -x RANK_STRIDE=4 \
    -x OMP_NUM_THREADS=2 \
    --oversubscribe \
    -np 8 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i H2O-32-RI-dRPA-TZ.inp \
    -o /tmp/32-H2O-RPA-solver-1GPU.txt
```

Or the solver step may be run on 4 MI250 GPUs using 16 MPI ranks and 4 OpenMP threads per rank with 2 processes sharing each GCD:
```
cd /opt/cp2k/benchmarks/QS_mp2_rpa/32-H2O/
mpirun \
    -x NUM_CPUS=128 \
    -x NUM_GPUS=8 \
    -x RANK_STRIDE=8 \
    -x OMP_NUM_THREADS=4 \
    --oversubscribe \
    -np 16 \
    --bind-to none \
    set_cpu_affinity.sh \
    set_gpu_affinity.sh \
    cp2k.psmp \
    -i H2O-32-RI-dRPA-TZ.inp \
    -o /tmp/32-H2O-RPA-solver-4GPU.txt
```

In the above-mentioned commands, the `NUM_CPUS`, `NUM_GPUS` and `RANK_STRIDE` variables are used by the helper scripts that set GPU and CPU affinity for CP2K processes and their threads. The `RANK_STRIDE` option allows the processes and their threads to be spread out and pinned to physical cores across the two sockets. If your system has a different configuration, please adjust the parameters accordingly.

A grep for `"CP2K     "` in the output files `/tmp/32-H2O-RPA-*.txt` will show the elapsed time for each run.
</details>

## Licensing Information

Your use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|CP2K|GNU GPL Version 2|[CP2k](https://www.cp2k.org/)<br />[CP2K License](https://github.com/cp2k/cp2k/blob/master/LICENSE)|
|OpenBlas|BSD 3-Clause|[OpenBlas](https://www.openblas.net/)<br /> [OpenBlas License](https://github.com/xianyi/OpenBLAS/blob/develop/LICENSE)|
|COSMA|BSD 3-Clause|[COSMA License](https://github.com/eth-cscs/COSMA/blob/master/LICENSE)|
|Libxsmm|BSD 3-Classe|[Libxsmm License](https://libxsmm.readthedocs.io/en/latest/LICENSE/)|
|Libxc|MPL v2.0|[Libxc License](https://github.com/ElectronicStructureLibrary/libxc)|
|SpLA|BSD 3-Clause|[SpLA License](https://github.com/eth-cscs/spla/blob/master/LICENSE)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.
 
## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

 
## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

