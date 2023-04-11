ARG IMAGE="rocm/dev-ubuntu-20.04:5.3-complete"

FROM ${IMAGE}

ARG LAMMPS_BRANCH="stable_23Jun2022_update3"
ARG UCX_BRANCH="v1.13.1"
ARG OMPI_BRANCH="v4.1.4"

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

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

# Adding rocm/cmake to the PATH
ENV PATH=/opt/rocm/bin:/opt/rocm/profiler/bin:/opt/rocm/opencl/bin:/opt/cmake/bin:$PATH

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
    && ../contrib/configure-release --prefix=/opt/ucx \
          --with-rocm=/opt/rocm --without-knem \
          --without-xpmem  --without-cuda \
          --enable-optimizations  \
          --disable-logging \
          --disable-debug \
          --enable-assertions \
          --enable-params-check \
          --disable-examples \
    && make -j 8  \
    && make  install

# Install OpenMPI
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --help \
    && ../configure --prefix=/opt/ompi --with-ucx=/opt/ucx \
          --enable-mca-no-build=btl-uct  \
          --enable-mpi-f90 \
          --enable-mpi-c \
          --with-pmix CC=gcc  \
          --enable-mpi \
          --enable-mpi-fortran=yes \
          --disable-debug \
    && make -j 8 \
    && make install

# Adding OpenMPI and UCX to PATH
ENV PATH=/opt/ompi/bin:/opt/ucx/bin:$PATH

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
        -DCMAKE_INSTALL_PREFIX=../install \
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
   &&   cd ..

# Adding environment variable for running OMPI as ROOT
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
 
CMD ["/bin/bash"]
