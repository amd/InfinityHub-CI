# MIT License
#
# Copyright (c) 2023 Advanced Micro Devices, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This installs SpecFEM3D Cartesian via Spack

FROM ubuntu:22.04

ARG GPU_ARCH=gfx90a
ARG GPU_MODEL=MI250

# Note: Valid combinations are
#  GPU_ARCH   GPU_MODEL
#  gfx906     MI50
#  gfx908     MI100
#  gfx90a     MI210
#  gfx90a     MI250

RUN echo Building for GPU Architecture ${GPU_ARCH} and GPU Model ${GPU_MODEL}

RUN apt-get update -y

# make sure certs are up to date
RUN apt-get install -y --reinstall ca-certificates

RUN apt-get install -y build-essential apt-utils 

# Other system dependencies  (some entries will be removed in the future)
RUN apt-get update -y \
   && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y \
        g++              \
        gfortran         \
        libnuma-dev      \
        libgmp-dev       \
        libboost-all-dev \
        git              \
        wget             \
        autoconf         \
        libtool          \
        flex             \
        cmake            \
        tar              \
        pkg-config       \
        initramfs-tools  \
        unzip            \
        bison            \
        curl             \
        python3          \
        python3-distutils \
        tmux             \
        vim emacs  nano  \
        dos2unix         \
        bindfs           \
        sudo             \
        watch 



ENV EDITOR=/usr/bin/nano

#########################################
# install Spack 
#########################################

RUN git clone https://github.com/spack/spack /home/spack/ 

# enable to help verify the Spack installation locations if necessary
# RUN find /home -name spack
# RUN cat /home/spack/share/spack/setup-env.sh

RUN /home/spack/share/spack/setup-env.sh

ENV PATH=/home/spack/bin:$PATH 

# verify spack can run
RUN  spack -V 

# display what compiler(s) is available
RUN spack compiler list 

RUN spack list  >/home/spack/spack.packages.txt 
RUN cat /home/spack/spack.packages.txt 

RUN spack arch --known-targets >/home/spack/arch.targets.txt
RUN cat /home/spack/arch.targets.txt

# Add the default compiler 
RUN spack compiler add

RUN spack compiler find

#########################################
# make sure the c, c++ and fortran compilers are installed
#########################################

# RUN spack install gcc 

RUN gfortran -v
RUN gcc -v

# show what compilers are actually available
RUN spack compiler find

#########################################
# change install location to /opt/<packagename>
#########################################

# What we want to install and how we want to install it
# is specified in a manifest file (spack.yaml)

RUN mkdir /opt/spack-environment \
&&  (echo "spack:" \
&&   echo "  specs:" \
&&   echo "  - rocminfo" \
&&   echo "  config:" \
&&   echo "    install_tree: /opt/software/specfem3d" \
&&   echo "  view: /opt/specfem3d" \
&&   echo "  concretizer:" \
&&   echo "    unify: true" \
&&   echo "  ") > /opt/spack-environment/spack.yaml

# see https://spack-tutorial.readthedocs.io/en/sc20/tutorial_developer_workflows.html

RUN mkdir -p  /home/spack/var/spack/repos/builtin/packages/ucx/

# (using a slightly modified ucx package definition)
COPY ucx_package.py  /home/spack/var/spack/repos/builtin/packages/ucx/package.py
COPY specfem3dcartesian_package.py /home/spack/var/spack/repos/builtin/packages/specfem3d/package.py


#########################################
# Install the software and dependencies
#########################################

RUN cd /opt/spack-environment \
    && . /home/spack/share/spack/setup-env.sh  \
      &&  spack env  activate . \
      &&  spack add  llvm-amdgpu  \
      &&  spack add  hip  \
      &&  spack add  openmpi@4.1.4 fabrics=ucx ^ucx@1.14.1 +rocm ^hwloc +rocm amdgpu_target=${GPU_ARCH} +pci \
      &&  spack add  pmix  \
      &&  spack add  rocminfo  \
      &&  spack add  scotch  \
      &&  spack add  specfem3d +rocm amdgpu_target==${GPU_ARCH} amdgpu_model=${GPU_MODEL} \
      &&  spack install -v -j 16  --fail-fast


#########################################
# set up the default environment when the Container runs
#########################################

RUN echo "cd /opt/specfem3d "  > /etc/profile.d/spackenv.sh \
    && echo ". /home/spack/share/spack/setup-env.sh  " >> /etc/profile.d/spackenv.sh   \
    && echo "spack env  activate /opt/spack-environment " >> /etc/profile.d/spackenv.sh  \
    && echo "export PATH=/opt/specfem3d/bin:$PATH" >> /etc/profile.d/spackenv.sh \      
    && chmod a+x /etc/profile.d/spackenv.sh  

RUN  find /opt/specfem3d/tests | xargs chmod a+w   
RUN  find /opt/specfem3d/EXAMPLES | xargs chmod a+w   
RUN  find /opt/specfem3d/DATA  | xargs chmod a+w  
RUN  find /opt/specfem3d/OUTPUT_FILES | xargs chmod a+w  
RUN  rm -rf /tmp/*


#########################################
#  pull in the Benchmark code
#########################################

COPY benchmarks/ /opt/specfem3d/benchmarks/
RUN  ls -lsa /opt/specfem3d
RUN  find /opt/specfem3d/benchmarks | xargs chmod a+w
RUN  echo "export PATH=/opt/specfem3d/benchmarks:/opt/specfem3d/benchmarks/cartesian/files:$PATH" >> /etc/profile.d/spackenv.sh
RUN  find   /opt/specfem3d/ | grep "\.sh" | xargs chmod a+x | true
RUN  find   /opt/specfem3d/ | grep "\.sh" | xargs ls -lsa 

ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

ENV OMPI_MCA_pml=ucx \
    OMPI_MCA_osc=ucx \
    OMPI_MCA_pml_ucx_tls=tcp,sm,rocm \
    UCX_TLS=all \
    OMPI_MCA_pml_ucx_devices=any 

#  use this for debugging any run time communication issue:
#    OMPI_MCA_pml_ucx_verbose=100

# by default, use -l option to make sure the /etc/profile.d/spackenv.sh script runs

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l", "-c", "$*", "--" ]
CMD [ "/bin/bash" ]
