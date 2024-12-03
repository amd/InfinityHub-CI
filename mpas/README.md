# MPAS
Instructions are provided to build Model for Prediction Across Scales (MPAS), using the Cray Compiler on a HPE HPC environment. This document is a guide and requires modifications based on the users specific environment. No pre-built binaries or Docker type Containers are provided for MPAS.

## Overview

The Model for Prediction Across Scales (MPAS) is a collaborative project for developing atmosphere, ocean, and other earth-system simulation components for use in climate, regional climate, and weather studies. The primary development partners are the climate modeling group at Los Alamos National Laboratory (COSIM) and the National Center for Atmospheric Research. Both primary partners are responsible for the MPAS framework, operators, and tools common to the applications; LANL has primary responsibility for the ocean model, and NCAR has primary responsibility for the atmospheric model.

The MPAS framework facilitates the rapid development and prototyping of models by providing infrastructure typically required by model developers, including high-level data types, communication routines, and I/O routines. By using MPAS, developers can leverage pre-existing code and focus more on development of their model.

More information can be found here:  [https://mpas-dev.github.io/](https://mpas-dev.github.io/)

  

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Dependencies 
The Dependencies for the build are:

- ### MPAS Source Code
    Location: [MPAS tar file](https://github.com/MPAS-Dev/MPAS-Model)  
    Branch: `master`

- ### HDF5
    Location: [HFD5 tar file](https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_12_3/src/hdf5-1.12.3.tar.gz)  
    Branch: `v1.12.3`  

- ### PnetPDF
    Location: [PNetPDF tar file](https://parallel-netcdf.github.io/Release/pnetcdf-1.12.2.tar.gz)  
    Branch: `v1.12.2`

- ### NetCDF
    Location: [NetCDF repo](https://github.com/Unidata/netcdf-c.git)  
    Branch: `v4.8.0`

- ### NetFortran
    Location: [NetFortran](https://github.com/Unidata/netcdf-fortran.git)  
    Branch: `v4.5.3`



## Building Application

----------

**Prerequisites:**

AMD GPU offloading is enabled only through the Cray ftn compiler (CCE 16) at this time. Appropriate modules must be loaded (e.g.,  `rocm/5.5.1`  and  `craype-accel-amd-gfx90a`).

The following libraries must be installed:  
- NETCDF  (V 4.8.0)
- PNETCDF  (V 1.12.2)
- HDF5 (V 1.12.3)
- ParallelIO ([https://github.com/NCAR/ParallelIO](https://github.com/NCAR/ParallelIO)  )

  
NETCDF, HDF5 and PNETCDF should already be provided on most HPE systems. If not, the user is responsible for providing standard builds with  `CC=cc`  and  `FC=ftn`.

To build ParallelIO, follow these instructions:
```
git clone https://github.com/NCAR/ParallelIO  
cd ParallelIO && mkdir build && cd build  
cmake .. CC=cc FC=ftn \  
-DNetCDF_C_PATH=/path/to/netcdf \  
-DNetCDF_Fortran_PATH=/path/to/netcdf \  
-DPnetCDF_PATH=/path/to/pnetcdf \  
-DCMAKE_INSTALL_PREFIX=… \  
-DCMAKE_Fortran_FLAGS=-ef  
make -j8 install
```
Minimum 2 GPUs (or 1 MI250/Mi250X GPU) required for this application. GPU-aware MPI is also required.

**Download MPAS-Model source code**

Obtain the MPAS-Model source code using the following commands:
```
git clone https://github.com/jychang48/MPAS-Model.git 
cd MPAS-Model  
git checkout atmosphere/develop-openacc-AMD-ftnpass
```


**Download JW Baroclinc Wave benchmark:**

Download and extract the tar file from here:  [**http://www2.mmm.ucar.edu/projects/mpas/test_cases/v7.0/jw_baroclinic_wave.tar.gz**](http://www2.mmm.ucar.edu/projects/mpas/test_cases/v7.0/jw_baroclinic_wave.tar.gz)

**Environment Variables:**  
Following environmental variables must be set for building MPAS:
```
NETCDF=/path/to/netcdf  
PNETCDF=/path/to/pnetcdf  
PIO=/path/to/ParallelIO  
USE_PIO2=true  
OPENMP_AMD_OFFLOAD=true
```
**Compiling init_atmosphere_model:**  
Execute the following make command inside MPAS-Model:
```
cd /path/to/MPAS-Model  
make CORE=init_atmosphere ftn-offload  
cp init_atmosphere_model /path/to/jw_baroclinic_wave
```
  
This will create a new binary called  `init_atmosphere_model`. Copy this binary into the benchmark directory:

`cp init_atmosphere_model /path/to/jw_baroclinic_wave`

**Compiling atmosphere_model:**  
Execute the following make command inside MPAS-Model:
```
make CORE=init_atmosphere clean  
make CORE=atmosphere ftn-offload
```
  
This will create a new binary called  `atmosphere_model`. Copy this binary into the benchmark directory:

`cp atmosphere_model /path/to/jw_baroclinic_wave`

**Preprocessing with init_atmosphere_model:**  
Execute the following make command inside  `/path/to/jw_baroclinic`:

`srun -n 1 ./init_atmosphere_model`

This will create a new filed called  `x1.40962.init.nc`  and only needs to be created once.

## Running The Application

----------

**2 GPUs/GCDs:**  
Set the following runtime environment variables:
```
AMD_DIRECT_DISPATCH=1  
ROC_ACTIVE_WAIT_TIMEOUT=0  
MPAS_DYNAMICS_RANKS_PER_NODE=2  
MPAS_RADIATION_RANKS_PER_NODE=2  
MPICH_GPU_SUPPORT_ENABLED=1
```

Execute the following make command inside  `/path/to/jw_baroclinic_wave`:

`srun -n 4 ./atmosphere_model`

**4 GPUs/GCDs:**  
Set the following runtime environment variables:
```
AMD_DIRECT_DISPATCH=1  
ROC_ACTIVE_WAIT_TIMEOUT=0  
MPAS_DYNAMICS_RANKS_PER_NODE=4  
MPAS_RADIATION_RANKS_PER_NODE=2  
MPICH_GPU_SUPPORT_ENABLED=1
```

Execute the following make command inside  `/path/to/jw_baroclinic_wave`:

`srun -n 6 ./atmosphere_model`

**8 GPUs/GCDs:**  
Set the following runtime environment variables:
```
AMD_DIRECT_DISPATCH=1  
ROC_ACTIVE_WAIT_TIMEOUT=0  
MPAS_DYNAMICS_RANKS_PER_NODE=8  
MPAS_RADIATION_RANKS_PER_NODE=2  
MPICH_GPU_SUPPORT_ENABLED=1
```

Execute the following make command inside  `/path/to/jw_baroclinic_wave`:

`srun -n 10 ./atmosphere_model`



## Troubleshooting

----------

  
If run successfully, you should have a log file called  `log.atmosphere.role01.0000.out`.

For more information on MPAS, including visualization, please visit the official website:  [https://mpas-dev.github.io/](https://mpas-dev.github.io/)

## Known Issues

----------

This AMD GPU build recipe is only applicable to HPE/Cray systems with CCE 16.



## Example script to build Pre-reqs
----------
```
#!/bin/bash
module load PrgEnv-cray
module load craype-accel-amd-gfx90a
export MPAS_APPS=$HOME/software/build-mpas-apps
export LD_LIBRARY_PATH=${MPAS_APPS}/lib:${MPAS_APPS}/lib64:$LD_LIBRARY_PATH

export NETCDF=${MPAS_APPS}
export PNETCDF=${MPAS_APPS}
export PIO=$MPAS_APPS
export USE_PIO2=true
export OPENMP_AMD_OFFLOAD=true
export MPICH_GPU_SUPPORT_ENABLED=1

buildZLib=true
buildHDF5=true
buildPDF=true
buildNetCDF=true
buildNetFortran=true
buildPIO=true

if  [[ "$buildZLib" == true ]]; then
echo "making zlib..."
if [ ! -d "./zlib-1.2.11" ]; then
 wget https://sourceforge.net/projects/libpng/files/zlib/1.2.11/zlib-1.2.11.tar.gz
 tar -xvf zlib-1.2.11.tar.gz
fi
cd zlib-1.2.11
./configure --prefix=$MPAS_APPS && make -j8 install
cd ..
fi

if  [[ "$buildHDF5" == true ]]; then
echo "making hdf5..."
if [ ! -d "./hdf5-1.12.3" ]; then
  wget https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_12_3/src/hdf5-1.12.3.tar.gz
  tar -xvf hdf5-1.12.3.tar.gz
fi
cd hdf5-1.12.3
./configure --prefix=$MPAS_APPS --enable-parallel --with-default-api-version=v18 CC=cc FC=ftn --with-zlib=$MPAS_APPS && make -j8 install
cd ..
fi

if  [[ "$buildPDF" == true ]]; then
echo "making pnetcdf..."
if [ ! -d "./pnetcdf-1.12.2" ]; then
  wget https://parallel-netcdf.github.io/Release/pnetcdf-1.12.2.tar.gz
  tar -xvf pnetcdf-1.12.2.tar.gz
fi
cd pnetcdf-1.12.2
./configure --prefix=$MPAS_APPS CC=cc FC=ftn F77=ftn --disable-shared && make -j8 install
cd ..
fi

if  [[ "$buildNetCDF" == true ]]; then
echo "making netcdf-c..."
if [ ! -d "./netcdf-c" ]; then
 git clone -b v4.8.0 https://github.com/Unidata/netcdf-c.git
fi
cd netcdf-c
./configure --prefix=$MPAS_APPS --disable-dap --enable-pnetcdf CC=cc CPPFLAGS=-I$MPAS_APPS/include LDFLAGS=-L$MPAS_APPS/lib --disable-shared && make -j8 install
cd ..
fi

if  [[ "$buildNetFortran" == true ]]; then
echo "making netcdf-fortran..."
set -xv
if [ ! -d "./netcdf-fortran" ]; then
 git clone  -b v4.5.3 https://github.com/Unidata/netcdf-fortran.git
ficd netcdf-fortran
  ./configure --prefix=$MPAS_APPS FC=ftn CC=cc --disable-dap F77=ftn CPPFLAGS=-I$MPAS_APPS/include LDFLAGS=-L$MPAS_APPS/lib --disable-shared LIBS="-L$MPAS_APPS/lib -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lm -lz" && make -j8 install FCFLAGS=-ef
cd ..
fi

if  [[ "$buildPIO" == true ]]; then
echo "making PIO..."
if [ ! -d "./ParallelIO" ]; then
  git clone https://github.com/NCAR/ParallelIO.git
fi
cd ParallelIO
rm -rf build && mkdir build
cd build
CC=cc FC=ftn cmake .. \
    -DNetCDF_C_PATH=$MPAS_APPS \
    -DNetCDF_Fortran_PATH=$MPAS_APPS \
    -DPnetCDF_PATH=$MPAS_APPS \
    -DCMAKE_INSTALL_PREFIX=$MPAS_APPS \
    -DCMAKE_Fortran_FLAGS="-ef"
make -j8
make  install
cd ../..
fi
----------
```

## Example Script to build MPAS
----------
```

MPAS_ZIP="./MPAS-Model-atmosphere-develop-openacc-AMD-ftnpass.zip"

#######################################33
# Load the required modules
##########################################

err=false

BuildJW=true
BuildMPAS=true

# Add path for ROCm 5.5.1 not otherwise provided 
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm-5.5.1/lib

module purge

echo Using ROCm version:
cat  /opt/rocm/.info/version


module load PrgEnv-cray
module load craype-accel-amd-gfx90a
module load rocm

export MPAS_APPS=$HOME/software/build-mpas-apps
export LD_LIBRARY_PATH=${MPAS_APPS}/lib:${MPAS_APPS}/lib64:$LD_LIBRARY_PATH
export NETCDF=${MPAS_APPS}
export PNETCDF=${MPAS_APPS}
export PIO=${MPAS_APPS}
export USE_PIO2=true
export OPENMP_AMD_OFFLOAD=true
export MPICH_GPU_SUPPORT_ENABLED=1

#######################################
# extract JW Wave code
#######################################

if $BuildJW ; then
   if [ ! -e "./jw_baroclinic_wave.tar.gz" ] ; then
        echo Error jw_baroclinic_wave.tar.gz file not found in local directory
        exit  1
   fi

   if [ ! -d "./jw_baroclinic_wave" ] ; then
        tar -xvf jw_baroclinic_wave.tar.gz
   fi

fi

if $BuildMPAS ; then
   if [ ! -e "${MPAS_ZIP}" ] ; then
        echo Error  ${MPAS_ZIP} file not found in local directory
        exit  1
   fi

   if [ ! -d "./MPAS-Model-atmosphere-develop-openacc-AMD-ftnpass" ] ; then
        unzip ${MPAS_ZIP}
   fi

fi

############################################
# using the MPAS Makefile build the JW code
############################################

if $BuildJW ; then

   if [ ! -d "./MPAS-Model-atmosphere-develop-openacc-AMD-ftnpass" ] ; then
           echo Error - can not find the MPAS-Model-atmosphere-develop-openacc-AMD-ftnpass directory
           exit  1
   fi

   pushd MPAS-Model-atmosphere-develop-openacc-AMD-ftnpass

     echo
     echo Building init_atmosphere inside the MPAS-Model dir $CWD
     echo
     sleep 4

     rm -f init_atmosphere*
     rm -f atmosphere_model*

     make clean CORE=atmosphere_model

     make  -j 8 CORE=init_atmosphere CRAY_CPU_TARGET=x86-64 ftn-offload

     # copy the init_atmospere model from the MPAS dir to the JW dir
     
     echo
     echo copy the init_atmospere model from the MPAS dir to the JW dir
     echo
     sleep 2

     if [ ! -e "./init_atmosphere_model" ] ; then
             echo Error - did not build the init_atmosphere_model file !!!
             exit 1
     fi

     if [ ! -d "../jw_baroclinic_wave" ] ; then
             echo Error - unable to find ../jw_baroclinic.wave directory !
             exit 1
     fi

     echo
     echo Building init_atmosphere
     echo
     sleep 4

     make clean CORE=init_atmosphere ftn-offload     
     
    echo copying  init_atmosphere_model to ../jw_baroclinic_wave/.
     cp -p  init_atmosphere_model ../jw_baroclinic_wave/.

     echo
     echo Done Building init_atmosphere
     echo

     echo
     echo Running init_atmosphere
     echo
     sleep 4

     p=$PWD
     cd ../jw_baroclinic_wave
     srun -n 1 ./init_atmosphere_model

     if [ -e "x1.40962.init.nc" ] ; then
             echo File x1.40962.init.nc was created !
     fi

     if [ ! -e "x1.40962.init.nc" ] ; then
             echo Error - did not find x1.40962.init.rc in the jw_baroclinic-wave directory
             echo The MPAS build process failed.
             exit 1
     fi
     cd $p

     echo
     echo Building atmosphere
     echo
     sleep 4
     

     make clean CORE=init_atmosphere
     make ftn-offload CORE=atmosphere

     echo
     echo Done Building atmosphere
     echo

     if [ -e './atmosphere_model' ] ; then
             echo atmosphere_model has been created. see ./MPAS-Model-atmosphere-develop-openacc-AMD-ftnpass/atmosphere_model
     else
             echo Error - atmosphere_model WAS NOT CREATED !
             exit 1
     fi

   popd

fi     

```

## Licensing Information

----------

Your use of this application is subject to the terms of the BSD-3 License (https://opensource.org/licenses/BSD-3-Clause) as set forth below. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

Copyright © 2024 Advanced Micro Devices, Inc. (AMD)

Copyright © 2013, Los Alamos National Security, LLC (LANS) (Ocean: LA-CC-13-047; Land Ice: LA-CC-13-117) and the University Corporation for Atmospheric Research (UCAR)  
All rights reserved.

LANS is the operator of the Los Alamos National Laboratory under Contract No. DE-AC52-06NA25396 with the U.S. Department of Energy. UCAR manages the National Center for Atmospheric Research under Cooperative Agreement ATM-0753581 with the National Science Foundation. The U.S. Government has rights to use, reproduce, and distribute this software. NO WARRANTY, EXPRESS OR IMPLIED IS OFFERED BY LANS, UCAR OR THE GOVERNMENT AND NONE OF THEM ASSUME ANY LIABILITY FOR THE USE OF THIS SOFTWARE. If software is modified to produce derivative works, such modified software should be clearly marked, so as not to confuse it with the version available from LANS and UCAR.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3.  Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Additional Licensing Information
----------
Your access and use of the referenced software is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using the referenced, you are agreeing to fully comply with the terms of the respective  licenses. If you do not agree to the terms of this license, do not access or use the referenced software.

The application requires the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|MPAS|LANS / UCAR custom clause|[MPAS License](https://github.com/MPAS-Dev/MPAS-Model/blob/master/LICENSE)|
|HDF5|BSD-style Open Source|[HDF License](https://support.hdfgroup.org/products/licenses.html)|
|PnetCDF|Northwestern University and Argonne National Laboratory custom|[PnetCDF License](https://github.com/Parallel-NetCDF/PnetCDF/blob/master/COPYRIGHT)|
|NetCDF|UCAR custom clause|[NetCDF License](https://www.unidata.ucar.edu/software/netcdf/copyright.html)|
|NetFortran|UCAR custom clause/Apache V2.0|[NetFortran License](https://github.com/Unidata/netcdf-fortran/blob/main/COPYRIGHT)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|

Additional third-party content may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
----------

The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution

----------

© 2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.

© 2024 Advanced Micro Devices, Inc.
