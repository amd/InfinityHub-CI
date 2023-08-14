ARG IMAGE="rocm/dev-ubuntu-20.04:5.3-complete"

FROM ${IMAGE}

ARG ROCHPCG_BRANCH="master"
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
    m4 \
  && apt-get clean

RUN echo "gfx906"  > /opt/rocm/bin/target.lst \
    &&  echo "gfx908"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx90a"  >> /opt/rocm/bin/target.lst

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

# Adding rocm/cmake to the PATH
ENV PATH=$ROCM_PATH/bin:$ROCM_PATH/profiler/bin:$ROCM_PATH/opencl/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$LIBRARY_PATH \
    C_INCLUDE_PATH=$ROCM_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$CPLUS_INCLUDE_PATH \
    CPATH=$ROCM_PATH/include:$CPATH \
    INCLUDE=$ROCM_PATH/include:$INCLUDE \
    LC_ALL=C

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
    &&  make  install \
    && cd .. && rm -rf /ucx

# Install OpenMPI
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --prefix=/opt/ompi --with-ucx=/opt/ucx \
        --enable-mca-no-build=btl-uct  \
        --with-pmix=internal \
        --enable-mpi \
        --enable-mpi-fortran=yes \
        --disable-debug \
    && make -j $(nproc) \
    && make install \
    && cd .. && rm -rf /ompi

# Adding OpenMPI and UCX to PATH
ENV PATH=$OMPI_PATH/bin:$UCX_PATH/bin:$PATH \
    LD_LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$CPLUS_INCLUDE_PATH \
    CPATH=$OMPI_PATH/include:$UCX_PATH/include:$CPATH \
    INCLUDE=$OMPI_PATH/include:$UCX_PATH/include:$INCLUDE \
    PKG_CONFIG_PATH=$OMPI_PATH/lib/pkgconfig:$UCX_PATH/lib/pkgconfig:$PKG_CONFIG_PATH 

WORKDIR /opt
# Installing rocHPCG
RUN git clone -b ${ROCHPCG_BRANCH} https://github.com/ROCmSoftwarePlatform/rocHPCG.git \
  && cd rocHPCG \
  && chmod a+x install.sh \
  && ./install.sh \
      --with-mpi=/opt/openmpi  \
      --with-rocm=/opt/rocm \
      --gpu-aware-mpi=ON \
      --with-openmp=ON \
      --with-memmgmt=ON \
      --with-memdefrag=ON \
  && rm -f /opt/rocm/bin/hpcg \
  && ln -s /opt/rocHPCG/build/release/bin/rochpcg /opt/rocm/bin/hpcg

# Adding environment variable for Running as ROOT and set MCA pml to UCX
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx

CMD ["/bin/bash"]

