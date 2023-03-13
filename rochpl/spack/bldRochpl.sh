#!/bin/bash
#
# A script that will create an instance of the rocHPL application via Spack.
#
# We expect to have these files:
#
# rochpl.package.py    spack definition of building rochpl
#
# This currently assumes using the Ubuntu 20.04 O/S image 
# and an AMD ROCm(tm) 5.3.3 application image.
#
# Spack is an open source project that offers a package management framework and tool for installing complex scientific software.
# It is designed to support multiple versions and configurations of a software on many different platforms and environments.
# Spack is development by Lawrence Livermore National Laboratory.

# Note: run these two commands to install Spack:
# cd ~
# git clone -c feature.manyFiles=true https://github.com/spack/spack.git

source  $HOME/spack/share/spack/setup-env.sh
echo $SPACK_ROOT
#
mkdir  -p ~/spack/var/spack/repos/builtin/packages/rochpl/
cp -p rochpl.package.py ~/spack/var/spack/repos/builtin/packages/rochpl/package.py
spack env create  -d .
#

spack env activate -p .

# spack clean -a
# spack clean -m
 
# for rebuild:
# spack uninstall --all --remove -R  -y rochpl

# for omp.h
find /usr -name omp.h
export HIPCC_COMPILE_FLAGS_APPEND="-I /usr/lib/gcc/x86_64-linux-gnu/9/include/"

spack add rochpl +rocm amdgpu_target=\"gfx906,gfx908,gfx90a\"   build_type=Release

spack install  --overwrite --no-cache

# present an easy path to the installed benchmark code

rc=$?

if (( $rc == 0 )); then
  rm -f benchmark
  ln -s `spack location --install-dir rochpl` benchmark
  ls -lsa benchmark
fi
