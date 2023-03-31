ARG IMAGE="rocm/dev-ubuntu-20.04:5.3-complete"

FROM ${IMAGE}

ARG ROCHPCG_BRANCH="master"
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
    &&  git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
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
    &&  make -j $(nproc)  \
    &&  make  install

# Install OpenMPI
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --prefix=/opt/ompi --with-ucx=/opt/ucx \
        --enable-mca-no-build=btl-uct  \
        --with-pmix CC=gcc  \
        --enable-mpi \
        --enable-mpi-fortran=yes \
        --disable-debug \
    && make -j $(nproc) \
    && make install

# Adding OpenMPI and UCX to PATH
ENV PATH=/opt/ompi/bin:/opt/ucx/bin:$PATH

# Installing rocHPCG
RUN git clone -b ${ROCHPCG_BRANCH} https://github.com/ROCmSoftwarePlatform/rocHPCG.git \
  && cd rocHPCG \
  && chmod a+x install.sh \
  && DEBIAN_FRONTEND=noninteractive \
    ./install.sh -di --with-mpi=/opt/openmpi  \
    --with-rocm=/opt/rocm \
    --gpu-aware-mpi=ON \
    --with-openmp=ON \
    --with-memmgmt=ON \
    --with-memdefrag=ON \
  && rm -f /opt/rocm/bin/hpcg \
  && ln -s /opt/rocm/bin/rochpcg /opt/rocm/bin/hpcg

# Adding environment variable for Running as ROOT and set MCA pml to UCX
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx

CMD ["/bin/bash"]

