# SPECFEM3D

## Overview
SPECFEM3D Cartesian (or SPECFEM3D), simulates acoustic (fluid), elastic (solid), coupled acoustic/elastic, poroelastic or seismic wave propagation in any type of conforming mesh of hexahedra (structured or not.) It can, for instance, model seismic waves propagating in sedimentary basins or any other regional geological model following earthquakes. It can also be used for non-destructive testing or for ocean acoustics.

For more information about SPECFEM3D Cartesian, visit

-   [https://geodynamics.org/resources/specfem3dcartesian](https://geodynamics.org/resources/specfem3dcartesian)

We thank the Computational Infrastructure for Geodynamics (CIG) for hosting SPECFEM3D Cartesian which is supported by the National Science Foundation award NSF-0949446 and NSF-1550901.

 This documentation supports the implementation of the SPECFEM3D Cartesian benchmark on top of AMD's ROCm platform.

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 


For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation)
* [ROCm Examples](https://github.com/amd/rocm-examples)


## Build Recipes
    - [Docker/Singularity Build](/specfem3d/docker/)
    - [Spack Build](/specfem3d/spack-docker/)
> **Note:**  
> The version of libxml2 and hwloc that come with Ubuntu and OpenMPI create a runtime error with SpecFEM3D-Cartecian.  
> Recommended versions: 
> - libxml2:    2.10.4 
> - hwloc:  2.12.0

## Running SPECFEM3D Benchmarks
SPECFEM3D provides an example test at the root of the [GitHub repo](https://github.com/SPECFEM/specfem3d/).
The [run_this_example.sh](https://github.com/SPECFEM/specfem3d/blob/master/run_this_example.sh) will build a small mesh, generate a database from the mesh and run the SPECFEM3D solver, generating output files in place at `./OUTPUT_FILES`.

AMD has provided a set [SPECFEM3D Benchmark scripts](/specfem3d/docker/benchmarks/) that can be downloaded and are 
These benchmark scripts are located `/opt/specfem3d/benchmarks/` within the Docker/Singularity containers. 

These scripts can be run at 1, 2, 4, or 8 GPUs by `#` with the desired number of GPUs
`./run_this_example.sh #`

> Note: If no value is given, 1 GPU is used. 

Other examples are available in subdirectories of /opt/specfem3d/EXAMPLES. 
> Note: that the examples may need to be modified to choose between using CPU or GPU mode, via the various PAR files.

## Licensing Information
Your use of this SPECFEM3D application (“Application”) is subject to the terms of the BSD-2 License ([https://opensource.org/licenses/BSD-2-Clause](https://opensource.org/licenses/BSD-2-Clause)) as set forth below. By accessing or using this Application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application. For the avoidance of doubt, this license supersedes any other agreement between AMD and you with respect to your access or use of the Application.

BSD 2 Clause

Copyright © 2023, Advanced Micro Devices, Inc. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The Application specifications provided includes the following separate and independent components: 
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|SpecFEM 3d Cartesian |GNU GPl 3 Clause|[SpecFEM 3d Cartesian](https://specfem3d.readthedocs.io/en/latest/01_introduction/)<br />[SpecFEM 3d Cartesian License](https://specfem3d.readthedocs.io/en/latest/D_license/#license)|
|BLIS|BSD 3-Clause|[BLIS License](https://github.com/amd/blis/blob/master/LICENSE)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.   

## Notices and Attribution
© 2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.  

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein.  Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.    

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
