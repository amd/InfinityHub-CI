ARG IMAGE="rocm/dev-ubuntu-22.04:5.4.2"

FROM ${IMAGE}

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

ENV ROCM_HOME=/opt/rocm \
    UCX_HOME=/opt/ucx \
    OMPI_HOME=/opt/ompi

# Adding rocm/cmake to the Environment 
ENV PATH=$ROCM_HOME/bin:$ROCM_HOME/profiler/bin:$ROCM_HOME/opencl/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_HOME/lib:$ROCM_HOME/lib64:$ROCM_HOME/llvm/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ROCM_HOME/lib:$ROCM_HOME/lib64:$LIBRARY_PATH \
    C_INCLUDE_PATH=$ROCM_HOME/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$ROCM_HOME/include:$CPLUS_INCLUDE_PATH \
    CPATH=$ROCM_HOME/include:$CPATH \
    INCLUDE=$ROCM_HOME/include:$INCLUDE

WORKDIR /tmp

# Install UCX
RUN cd /tmp/ \
    && git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
    && cd ucx \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && ../contrib/configure-release --prefix=$UCX_HOME \
        --with-rocm=$ROCM_HOME \
        --without-knem \
        --without-xpmem  \
        --without-cuda \
        --enable-optimizations  \
        --disable-logging \
        --disable-debug \
        --disable-examples \
    && make -j $(nproc)  \
    && make install

# Install OpenMPI
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --prefix=$OMPI_HOME --with-ucx=$UCX_HOME \
        --enable-mca-no-build=btl-uct  \
        --without-verbs \
        --with-pmix  \
        --enable-mpi \
        --enable-mpi-fortran=yes \
        --disable-debug \
    && make -j $(nproc) \
    && make install

# Adding OpenMPI and UCX to Environment
ENV PATH=$OMPI_HOME/bin:$UCX_HOME/bin:$PATH \
    LD_LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$C_INCLUDE_PATH \ 
    CPLUS_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$CPLUS_INCLUDE_PATH \ 
    CPATH=$OMPI_HOME/include:$UCX_HOME/include:$CPATH \
    INCLUDE=$OMPI_HOME/include:$UCX_HOME/include:$INCLUDE \
    PKG_CONFIG_PATH=$OMPI_HOME/lib/pkgconfig:$UCX_HOME/lib/pkgconfig:$PKG_CONFIG_PATH

# Install Additional Apps Below



# Adding environment variable for Running as ROOT and set MCA pml to UCX
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx

CMD ["/bin/bash"]

