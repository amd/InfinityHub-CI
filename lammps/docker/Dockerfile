ARG IMAGE="rocm/dev-ubuntu-20.04:5.3-complete"

FROM ${IMAGE}

ARG LAMMPS_BRANCH="stable_23Jun2022_update4"
ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"

# Update and Install basic Linux development tools
RUN rm /etc/apt/sources.list.d/* \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    ssh \
    make \
    vim \
    nano \
    libtinfo* \
    initramfs-tools \
    libelf-dev \
    numactl \
    wget \
    tmux \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libnuma* \
    gfortran \
    flex \
    hwloc \
  && apt-get clean

RUN echo "gfx906"  > /opt/rocm/bin/target.lst \
    &&  echo "gfx908"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx90a"  >> /opt/rocm/bin/target.ls

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

# Adding rocm/cmake to the PATH
ENV ROCM_PATH=/opt/rocm \
    UCX_HOME=/opt/ucx \
    OMPI_HOME=/opt/ompi

# Adding rocm/cmake to the Environment 
ENV PATH=$ROCM_PATH/bin:$ROCM_PATH/profiler/bin:$ROCM_PATH/opencl/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$LIBRARY_PATH \
    C_INCLUDE_PATH=$ROCM_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$CPLUS_INCLUDE_PATH \
    CPATH=$ROCM_PATH/include:$CPATH \
    INCLUDE=$ROCM_PATH/include:$INCLUDE

WORKDIR /tmp

# Install UCX
RUN cd /tmp/ \
    && git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
    && ls \
    && pwd \
    && cd ucx \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && ../contrib/configure-release --prefix=$UCX_HOME \
          --with-rocm=/opt/rocm --without-knem \
          --without-xpmem  --without-cuda \
          --enable-optimizations  \
          --disable-logging \
          --disable-debug \
          --enable-assertions \
          --enable-params-check \
          --disable-examples \
    && make -j 8  \
    && make  install \
    && cd /tmp \
    && rm -rf *  

# Install OpenMPI
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --help \
    && ../configure --prefix=$OMPI_HOME --with-ucx=$UCX_HOME \
          --enable-mca-no-build=btl-uct  \
          --enable-mpi-f90 \
          --enable-mpi-c \
          --with-pmix=internal \
          --enable-mpi \
          --enable-mpi-fortran=yes \
          --disable-debug \
    && make -j 8 \
    && make install \
    && cd /tmp \
    && rm -rf *  
    

# Adding OpenMPI and UCX to Environment
ENV PATH=$OMPI_HOME/bin:$UCX_HOME/bin:$PATH \
    LD_LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$CPLUS_INCLUDE_PATH \
    CPATH=$OMPI_HOME/include:$UCX_HOME/include:$CPATH \
    INCLUDE=$OMPI_HOME/include:$UCX_HOME/include:$INCLUDE \
    PKG_CONFIG_PATH=$OMPI_HOME/lib/pkgconfig:$UCX_HOME/lib/pkgconfig:$PKG_CONFIG_PATH

# Installing LAMMPS
RUN cd /tmp \
  && git clone https://github.com/lammps/lammps.git \
  && cd lammps \
  && git checkout ${LAMMPS_BRANCH} \
  && cd .. \
  && mkdir build \
  && cd build \
  && cmake   -DPKG_KOKKOS=on \
        -DPKG_REAXFF=on \
        -DPKG_MANYBODY=on \
        -DPKG_ML-SNAP=on \
        -DPKG_MOLECULE=on \
        -DPKG_KSPACE=on \
        -DPKG_RIGID=on \
        -DBUILD_MPI=on \
        -DCMAKE_INSTALL_PREFIX=/opt/lammps \
        -DMPI_CXX_COMPILER=$(which mpicxx) \
        -DCMAKE_BUILD_TYPE=Release \
        -DKokkos_ENABLE_HIP=on \
        -DKokkos_ENABLE_SERIAL=on \
        -DCMAKE_CXX_STANDARD=14 \
        -DCMAKE_CXX_COMPILER=$(which hipcc) \
        -DKokkos_ARCH_VEGA90A=ON \
        -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON \
        -DCMAKE_CXX_FLAGS=-munsafe-fp-atomics \
        ../lammps/cmake \
    &&   make -j$(nproc) install \
    && cd /tmp/lammps \  
    && mv bench /opt/lammps/bench \
    && mv examples /opt/lammps/examples \
    && mv potentials /opt/lammps/potentials \
    && chmod -R a+rwx /opt/lammps \
    && cd /tmp \
    && rm -rf *  

WORKDIR /opt/lammps/bench 
# Adding environment variable for running OMPI as ROOT
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    PATH=$PATH:/opt/lammps/bin

CMD ["/bin/bash"]
