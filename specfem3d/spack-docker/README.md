# SPECFEM3D Spack Build Instructions

## Build System Requirements
- Git
- Spack (for local Spack build)
- Docker (for Docker build)

## Dependencies 
The Dependencies for the build are:

- ### specfem3d  source
    Location: [specfem3d repo](https://github.com/geodynamics/specfem3d)  
    Branch: `devel` of version 4.0.0  
    (or edit the version() call in [specfem3dcartesian_package.py](/specfem3dCartesian/docker/specfem3dcartesian_package.py))

- ### UCX 
    Location: [UXC repo](https://github.com/openucx/ucx)  
    Branch: `v1.14.1`   

- ### Open MPI
    Location: [OpenMPI repo](https://github.com/open-mpi/ompi)  
    Branch: `v4.1.4`  


## Docker Version
Download the [specfem3d Docker script and other build code](/specfem3d/docker-spack) if you want build a Docker Container version of the code.

The Docker image can be built using the provided Dockerfile source file. Navigate to inside `docker` directory, issue the command:
```
sudo docker build --network=host -t specfem3d -f Dockerfile .
```
Please note that the period (dot) at the end of the command is actually part of the docker build syntax and must be included in your command.

This will build a Docker image named (tagged) specfem3d, from the input file docker/Dockerfile, starting in the current directory (".").
 
The build targets the MI250/gfx90a system, by default, and may be changed using `--build-arg GPU_ARCH=`  and `--build-arg GPU_MODEL=`  as appropriate.

## Without Docker Version
Download the [specfem3d Docker and Spack script and other build code](/specfem3d/docker-spack)

- The package contains a Docker Container specification that uses Spack to build the code. A standalone Spack specification can be created by extracting the Spack command. (*Unless you are planning on creating the package on your own, please use the Docker Version section of this document*)

- `specfem3dcartesian_package.py` contains the Spack specification for building SPECFEM3D. This file points to the source, defines prerequisite packages and sets some build arguments.  Note that SPECFEM3D is currently defined externally from Spack, via the specfem3dcartesian_package.py file and it will, eventually, be pushed to the standard Spack repository.
 
- `ucx_package.py` contains a slightly modified Spack UCX package that is required to use this code with AMD ROCm GPUs. 

- If you do not already have Spack installed, run the command to install Spack ( `git clone -c feature.manyFiles=true https://github.com/spack/spack.git`) starting in your home directory. 

To run the Spack build for SPECFEM3D, copy the provided specfem3d and ucx package to your Spack repo. For example,  
```
cp ucx_package.py                   $HOME/spack/var/spack/repos/builtin/packages/ucx/package.py  
cp specfem3dcartesian_package.py    $HOME/spack/var/spack/repos/builtin/packages/specfem3d/package.py  
```
Extract and run the Spack commands from the Dockerfile. You will need to edit the commands to remove the Docker related syntax.

On the first run, the build will take multiple hours to build all the components. 

## Locating the SPECFEM3D Spack Image
Spack compiles and links code into fairly self contained packages using the Linux rpath facilities. The location of the built package may be found using the `spack location` command:
```
source  $HOME/spack/share/spack/setup-env.sh
spack location --install-dir specfem3d
```
Use a symbolic link to create an easy to remember location, such as a "benchmark" directory (note the back ticks around the spack command):
```
ln -s `spack location --install-dir specfem3d` benchmarks
cd benchmarks
```
Inside the `benchmark` directory is the README.md file that is  provides instructions to run the application. 

The PATH environment variable may be extended to put the application directory on the active path:
```
spack location --install-dir specfem3d  
cd   [to output above]  
export PATH=\$PWD/bin:\$PATH  
```

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
