# CP2K Bare Metal Build Instructions 

## Overview
This document provides instructions on how to do a bare metal install of CP2K in a Linux environment. 

## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver |
| ---- | ---- | ----------------- | ------------ |
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) | Ubuntu 20.04 <br> Ubuntu 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v6.x compatibility<br>ROCm v5.x compatibility |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## System Dependencies
|Application|Minimum|Recommended|
|---|---|---|
|Git|Latest|Latest|
|ROCm|5.3.0|latest|
|OpenMPI|4.0.3|5.0.3|
|UCX|1.8.0|1.16.0|


## Installing CP2K using CP2K toolchain

1. Validate the Cluster/System has all of the above applications, with system path, library, and include environments set correctly. If you are unsure, the [Dockerfile](/cp2k/docker/Dockerfile) has examples of all useful configurations listed after the `ENV` commands. 
2. Clone the [CP2K GIT repo](https://github.com/cp2k/cp2k.git) into your workspace. 
```bash
git clone --recursive https://github.com/cp2k/cp2k.git
```
3. Install CP2K dependencies with CP2Ks toolchains script.  
For more Details for how the toolchain works visit [cp2k/tool/Toolchain](https://github.com/cp2k/cp2k/tree/master/tools/toolchain) the CP2K repo.

> NOTE: With the Mi250 below the toolchain will configure the CP2K Dependencies for all AMD GPUs.  
> To use another GPU follow steps provided for updating the make files. 

```bash
cd cp2k/tools/toolchain
./install_cp2k_toolchain.sh \
            -j8 \
            --install-all \
            --mpi-mode=openmpi \
            --math-mode=openblas \
            --gpu-ver=Mi250 \
            --enable-hip \
            --with-gcc=system \
            --with-openmpi=system \
            --with-mkl=no \
            --with-acml=no \
            --with-ptscotch=no \
            --with-superlu=no \
            --with-pexsi=no \
            --with-quip=no \
            --with-plumed=no \
            --with-sirius=no \
            --with-gsl=no \
            --with-libvdwxc=no \
            --with-spglib=no \
            --with-hdf5=no \
            --with-spfft=no \
            --with-libvori=no \
            --with-libtorch=no \
            --with-elpa=no \
            --with-deepmd=no \
```

4. Update generated psmp file.
The generated psmp file must be modified. The following command can be used to implement the required modification:  
`sed -i 's/hip\/bin/bin/' ./tools/toolchain/install/arch/local_hip.psmp`  
> **Optional:**   
> If building for any GPUs other than MI200 series, update the `AMDGPU_TARGETS` variable to the correct architecture and run the following commands.  
>Example for the MI300 series:  
>```bash
>EXPORT $AMDGPU_TARGETS=gfx942
>sed -i "s/gfx90a/$AMDGPU_TARGETS/" ./tools/toolchain/install/arch/local_hip.psmp
>sed -i "s/gfx90a/$AMDGPU_TARGETS/" ./exts/build_dbcsr/Makefile
>```

5. Copy tool chain build files to `cp2k/arch`
```bash
cp cp2k/tools/toolchain/install/arch/* cp2k/arch/.
```

6. Tuning for build. (Optional)
CP2K will build without inclusion of these tuning flags, but it is recommended for performance to include these depending on what kind of Benchmark/Workload to be run. 

- RPA Benchmarks/Workloads:  
This executable has been built without the DBCSR GPU backend as it improves the performance of Random Phase Approximation (RPA) benchmarks.
```bash
echo "DFLAGS      = -D__LIBXSMM  -D__parallel -D__FFTW3  -D__LIBINT -D__LIBXC -D__SCALAPACK -D__COSMA -D__OFFLOAD_GEMM   -D__SPLA   -D__HIP_PLATFORM_AMD__ -D__OFFLOAD_HIP" >> cp2k/arch/local_hip.psmp
```

- DFT Benchmarks/Workloads:  
This executable has been built without the PW GPU backend as it improves the performance of Linear Scaling Density Functional Theory 
```bash
echo "DFLAGS      = -D__LIBXSMM  -D__parallel -D__FFTW3  -D__LIBINT -D__LIBXC -D__SCALAPACK -D__COSMA -D__OFFLOAD_GEMM   -D__SPLA   -D__HIP_PLATFORM_AMD__ -D__OFFLOAD_HIP -D__DBCSR_ACC -D__NO_OFFLOAD_PW" >> cp2k/arch/local_hip.psmp
```

7. Build CP2K
```bash
make realclean ARCH=local_hip VERSION=psmp
make -j (nproc) ARCH=local_hip VERSION=psmp
```

8. Add Binary to PATH
The binary gets build in `cp2k/exe/local_hip`
```BASH
ln -s /path/to/cp2k/exe/local_hip /path/to/cp2k/bin 
export PATH=$PATH:/path/to/cp2k/bin
```

9. Build other binary. (Optional)
You may want both the RPA and DFT tuned binary. 
You will want to update the binary name to be descriptive of the build. 
In the container they are `cp2k.psmp.no_dbcsr_gpu` and `cp2k.psmp.no_pw_gpu` to give a descriptive name to the two binaries.
The best way to achieve that is to repeat steps 4-6 using the other tuned options. 

10. Add affinity scripts that help tune at runtime. 
[Two affinity scripts](/cp2k/docker/scripts/) have been provided that will help tune the CPU/GPU usage at runtime.
Adding these scripts to the location with the binary(s) or any directory in the system's `PATH` will allow a user to take advantage of these scripts that have been provided and how to use them which is provided [Running CP2K Benchmark](/cp2k/README.md#running-cp2k-benchmarks).


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
© 2022-24 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

