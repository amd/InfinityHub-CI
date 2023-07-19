ARG IMAGE="rocm/dev-ubuntu-22.04:5.4.2"

FROM ${IMAGE}

ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"
ARG APT_GET_APPS=""

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
    curl \
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
    hwloc ${APT_GET_APPS}\
  && apt-get clean \
  && ln -s /opt/rocm/llvm/bin/offload-arch /opt/rocm/bin/offload-arch

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

ENV ROCM_PATH=/opt/rocm \
    UCX_PATH=/opt/ucx \
    OMPI_PATH=/opt/ompi

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
    && cd ucx \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && ../contrib/configure-release --prefix=$UCX_PATH \
        --with-rocm=$ROCM_PATH \
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
    && ../configure --prefix=$OMPI_PATH --with-ucx=$UCX_PATH \
        --enable-mca-no-build=btl-uct  \
        --without-verbs \
        --with-pmix=internal \
        --enable-mpi \
        --enable-mpi-fortran=yes \
        --disable-man-pages \
        --disable-debug \
    && make -j $(nproc) \
    && make install

# Adding OpenMPI and UCX to Environment
ENV PATH=$OMPI_PATH/bin:$UCX_PATH/bin:$PATH \
    LD_LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$CPLUS_INCLUDE_PATH \
    CPATH=$OMPI_PATH/include:$UCX_PATH/include:$CPATH \
    INCLUDE=$OMPI_PATH/include:$UCX_PATH/include:$INCLUDE \
    PKG_CONFIG_PATH=$OMPI_PATH/lib/pkgconfig:$UCX_PATH/lib/pkgconfig:$PKG_CONFIG_PATH

# Install Additional Apps Below



# Adding environment variable for Running as ROOT and set MCA pml to UCX
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx

CMD ["/bin/bash"]

