# 
# This script builds a Docker based Container 
# for the HPL (rochpl) application, via Spack.
# It is based on AMD ROCm 5.3.2 code and 
# requires the host system to have a ROCm V 5.x kernel.
#
 
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    SPACK_ROOT=/usr/local \
    FORCE_UNSAFE_CONFIGURE=1

WORKDIR /home/user

# Install basic Spack requirements 

RUN  apt-get update \
     && apt-get install -y --no-install-recommends \
        autoconf \
        build-essential \
        ca-certificates \
        coreutils \
        curl \
        environment-modules \
        git \
        python \
        unzip \
        vim \
     && rm -rf /var/lib/apt/lists/*

# Install python 3.9 (Spack requirement)

RUN  apt-get update \
     && apt-get  install -y software-properties-common \
     && add-apt-repository ppa:deadsnakes/ppa \
     && apt-get install -y python3.9

RUN  echo "source $SPACK_ROOT/share/spack/setup-env.sh" \
      > /etc/profile.d/spack.sh

RUN cat /etc/profile.d/spack.sh

# Install spack 

RUN curl -s -L https://api.github.com/repos/spack/spack/tarball \
      | tar xzC  $SPACK_ROOT --strip 1

# Show where spack is installed 

RUN find $SPACK_ROOT -name spack


# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

#
# A Dockerfile that will create an instance of the rocHPL application via Spack.
#
# We expect the sources subdirectory will have the files:
#
# ./sources/rochpl.package.py    spack definition of building rochpl
#
# This currently builds a Ubuntu 20.04 O/S image and an AMD ROCm(tm) 5.3.2 based applications.
#
# Spack is an open source project that offers a package management framework and tool for installing complex scientific software.
# It is designed to support multiple versions and configurations of a software on many different platforms and environments.
# Spack is development by Lawrence Livermore National Laboratory.


# RUN env

# Other system dependencies  (some entries may be removed in the future)
RUN apt-get update -y \
   && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y \
        g++              \
        gfortran         \
        libnuma-dev      \
        libgmp-dev       \
        libboost-all-dev \
        autoconf         \
        libtool          \
        flex             \
        cmake            \
        tar              \
        pkg-config       \
        initramfs-tools  \
        unzip            \
        bison            \
        python3          \
        python3-distutils \
        tmux             \
        vim emacs        \
        dos2unix         \
        wget curl        \
        bindfs sudo

# HPL needs omp.h so add the required include directory
RUN find / -name omp.h
ENV HIPCC_COMPILE_FLAGS_APPEND="-I /usr/lib/gcc/x86_64-linux-gnu/9/include/"

# ROCm install based on: https://docs.amd.com/bundle/ROCm-Installation-Guide-v5.3.2/page/Introduction_to_ROCm_Installation_Guide_for_Linux.html

RUN apt-get update -y
RUN wget https://repo.radeon.com/amdgpu-install/5.3.2/ubuntu/focal/amdgpu-install_5.3.50302-1_all.deb
RUN apt-get install -y ./amdgpu-install_5.3.50302-1_all.deb
RUN amdgpu-install -y --usecase=hiplibsdk,rocm  --no-dkms

RUN  echo "gfx906"   >  /opt/rocm/bin/target.lst
RUN  echo "gfx908"   >> /opt/rocm/bin/target.lst
RUN  echo "gfx90a"   >> /opt/rocm/bin/target.lst

ENV ROCM_TARGET_LST=/opt/rocm/bin/target.lst

######################
# Install rocHPL via Spack
######################

# copy the rochpl package file into place

COPY ./sources/rochpl.package.py .

RUN mkdir -p /usr/local/var/spack/repos/builtin/packages/rochpl/ \
 && cp -p rochpl.package.py /usr/local/var/spack/repos/builtin/packages/rochpl/package.py   \
 && ls -lsa /usr/local/var/spack/repos/builtin/packages/rochpl/package.py \
 && cat /usr/local/var/spack/repos/builtin/packages/rochpl/package.py

RUN spack env create -d .  \
     && eval `spack env activate --sh . ` \
     && spack add rochpl +rocm amdgpu_target="gfx906,gfx908,gfx90a"  build_type=Release \
     && spack install


# create a benchmark directory to make it easier to run rochpl

RUN ln -s `spack location --install-dir rochpl` benchmark
RUN mkdir -p /opt
RUN ln -s `spack location --install-dir rochpl` /opt/rochpl

WORKDIR /home/user/benchmark

ENV PATH=/home/user/benchmark:/home/user/benchmark/bin:$PATH 

ENV  OMPI_MCA_pml=ucx \
     OMPI_MCA_osc=ucx \
     OMPI_MCA_pml_ucx_tls=any \
     OMPI_MCA_pml_ucx_devices=any \
     OMPI_MCA_pml_ucx_verbose=100

CMD ["/bin/bash"]
