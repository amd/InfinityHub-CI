ARG UBUNTU_VERSION="noble"

FROM ubuntu:${UBUNTU_VERSION}

ARG ROCM_URL="https://repo.radeon.com/amdgpu-install/7.0/ubuntu/noble/amdgpu-install_7.0.70000-1_all.deb"
ARG UCX_BRANCH="v1.19.0"
ARG UCC_BRANCH="v1.5.1"
ARG OMPI_BRANCH="v5.0.8"
ARG APT_GET_APPS=""
ARG AMDGPU_TARGETS="gfx908,gfx90a,gfx942"

# Update and Install basic Linux development tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        ssh \
        make \
        vim \
        nano \
        libtinfo-dev\
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
        libnuma-dev \
        gfortran \
        flex \
        hwloc \
        libstdc++-12-dev \
        libxml2-dev \
        python3-dev \
        python3-pip \
        unzip ${APT_GET_APPS}\
    && apt-get clean

RUN wget -qO- https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/rocm.gpg \
    && wget -O rocm.deb ${ROCM_URL} \
    && apt install -y ./rocm.deb \
    && amdgpu-install --usecase=rocm,hiplibsdk --no-dkms -y

RUN bash -c """IFS=',' read -r -a ARCH <<<${AMDGPU_TARGETS} \
        &&  for gpu_arch in \${ARCH[@]}; do \
            echo \$gpu_arch  >> /opt/rocm/bin/target.lst; \
        done""" \
    && chmod a+r /opt/rocm/bin/target.lst 

# # Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.30/cmake-3.30.5-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

ENV ROCM_PATH=/opt/rocm \
    UCX_PATH=/opt/ucx \
    UCC_PATH=/opt/ucc \
    OMPI_PATH=/opt/ompi \
    FC=amdflang \
    CC=amdclang \
    CXX=amdclang++ \
    AMDGPU_TARGETS=${AMDGPU_TARGETS}

# Adding rocm/cmake to the Environment 
ENV PATH=$ROCM_PATH/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:$ROCM_PATH/lib/llvm/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$LIBRARY_PATH \
    C_INCLUDE_PATH=$ROCM_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$CPLUS_INCLUDE_PATH \
    CMAKE_PREFIX_PATH=$ROCM_PATH/lib/cmake:$CMAKE_PREFIX_PATH

WORKDIR /tmp


# Install UCX
RUN git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
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

# Install UCC
RUN git clone -b ${UCC_BRANCH} https://github.com/openucx/ucc \
    && cd ucc \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && ../configure --prefix=${UCC_PATH} --with-rocm=${ROCM_PATH} --with-ucx=${UCX_PATH} --with-rccl=no --with-rocm-arch=all-arch-no-native \
    && make -j $(nproc) \
    && make install


# Install OpenMPI
RUN git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --prefix=$OMPI_PATH --with-ucx=$UCX_PATH \
        --with-ucc=${UCC_PATH} \
        --enable-mca-no-build=btl-uct  \
        --without-verbs \
        --with-pmix=internal \
        --enable-mpi \
        --enable-mpi-fortran=yes \
        --disable-man-pages \
        --disable-debug \
    && make -j $(nproc) \
    && make install

# Adding OpenMPI, UCX, and UCC to Environment
ENV PATH=$OMPI_PATH/bin:$UCX_PATH/bin:$UCC_PATH/bin:$PATH \
    LD_LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$UCC_PATH/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$UCC_PATH/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$UCC_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$UCC_PATH/include:$CPLUS_INCLUDE_PATH \
    PKG_CONFIG_PATH=$OMPI_PATH/lib/pkgconfig:$UCX_PATH/lib/pkgconfig/:$PKG_CONFIG_PATH  \
    OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    UCX_WARN_UNUSED_ENV_VARS=n

# Install Additional Apps Below




CMD ["/bin/bash"]

