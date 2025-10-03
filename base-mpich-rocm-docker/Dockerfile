ARG UBUNTU_VERSION="noble"

FROM ubuntu:${UBUNTU_VERSION}

ARG ROCM_URL="https://repo.radeon.com/amdgpu-install/7.0/ubuntu/noble/amdgpu-install_7.0.70000-1_all.deb"
ARG MPICH_BRANCH="v4.3.1"
ARG MPICH_DEVICE="ch4:ofi"
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
        unzip \
        ${APT_GET_APPS}\
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
    MPI_PATH=/opt/mpich \
    FC=amdflang \
    CC=amdclang \
    CXX=amdclang++ \
    AMDGPU_TARGETS=${AMDGPU_TARGETS}

# Adding rocm/cmake to the Environment 
ENV PATH=$ROCM_PATH/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib \
    LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64 \
    C_INCLUDE_PATH=$ROCM_PATH/include \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include \
    CMAKE_PREFIX_PATH=$ROCM_PATH/lib/cmake

WORKDIR /tmp


RUN git clone -b ${MPICH_BRANCH} --recursive https://github.com/pmodels/mpich.git \
    && cd mpich \
    && ./autogen.sh \
    && ./configure --with-device=${MPICH_DEVICE} --prefix=$MPI_PATH \
    && make install -j 8 \
    && rm -rf /tmp/mpich

# Adding Mpich Environment
ENV PATH=$MPI_PATH/bin:$PATH \
    LD_LIBRARY_PATH=$MPI_PATH/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$MPI_PATH/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$MPI_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$MPI_PATH/include:$CPLUS_INCLUDE_PATH \
    PKG_CONFIG_PATH=$MPI_PATH/lib/pkgconfig:$PKG_CONFIG_PATH

# Install Additional Apps Below

# CMD ["/bin/bash"]

