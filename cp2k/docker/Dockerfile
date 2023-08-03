ARG IMAGE="rocm/dev-ubuntu-20.04:5.4.3-complete"

FROM ${IMAGE}

ARG CP2K_BRANCH="v2023.1"
ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"
ARG GPU_VER="Mi250"

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
        wget \
        build-essential \
        autoconf \
        automake \
        gcc \
        g++ \
        gfortran \
        libboost-all-dev \
        libomp-dev \
        flex \
        initramfs-tools \
        libnuma-dev \
        pkg-config \
        libtinfo* \
        libelf-dev \
        numactl \
        tmux \  
        libtool \
        hwloc \
      && apt-get clean

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
      && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

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
    && cd ucx \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && ../contrib/configure-release --prefix=$UCX_HOME \
        --with-rocm=$ROCM_PATH \
        --without-knem \
        --without-xpmem  \
        --without-cuda \
        --enable-optimizations  \
        --disable-logging \
        --disable-debug \
        --enable-mt \
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
        --with-pmix=internal  \
        --enable-mpi \
        --enable-mpi-fortran=yes \
        --disable-man-pages \
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
    PKG_CONFIG_PATH=$OMPI_HOME/lib/pkgconfig:$UCX_HOME/lib/pkgconfig:$PKG_CONFIG_PATH \
    CP2K_DIR=/opt/cp2k

SHELL [ "/bin/bash", "-c" ]

WORKDIR /opt/    

# Get CP2K
RUN git clone --recursive -b ${CP2K_BRANCH} https://github.com/cp2k/cp2k.git \
      && cd cp2k/tools/toolchain \
      && ./install_cp2k_toolchain.sh \
            -j8 \
            --install-all \
            --mpi-mode=openmpi \
            --math-mode=openblas \
            --gpu-ver=${GPU_VER} \
            --enable-hip \
            --with-gcc=system \
            --with-openmpi=system \
            --with-mkl=no \
            --with-acml=no \
            --with-ptscotch=no \
            --with-superlu=no \
            --with-pexsi=no \
            --with-quip=no \
            --with-plumed=no \
            --with-sirius=no \
            --with-gsl=no \
            --with-libvdwxc=no \
            --with-spglib=no \
            --with-hdf5=no \
            --with-spfft=no \
            --with-libvori=no \
            --with-libtorch=no \
            --with-elpa=no \
      && cp ${CP2K_DIR}/tools/toolchain/install/arch/* ${CP2K_DIR}/arch \
      && echo "DFLAGS      = -D__LIBXSMM  -D__parallel -D__FFTW3  -D__LIBINT -D__LIBXC -D__SCALAPACK -D__COSMA -D__OFFLOAD_GEMM   -D__SPLA   -D__HIP_PLATFORM_AMD__ -D__OFFLOAD_HIP" >> ${CP2K_DIR}/arch/local_hip.psmp \
      && source ${CP2K_DIR}/tools/toolchain/install/setup \
      && cd ${CP2K_DIR}    \
      && make realclean ARCH=local_hip VERSION=psmp \
      && make -j 8 ARCH=local_hip VERSION=psmp \
      && cp ${CP2K_DIR}/exe/local_hip/cp2k.psmp ${CP2K_DIR}/exe/local_hip/cp2k.psmp.no_dbcsr_gpu \
      && cp ${CP2K_DIR}/tools/toolchain/install/arch/* ${CP2K_DIR}/arch \
      && echo "DFLAGS      = -D__LIBXSMM  -D__parallel -D__FFTW3  -D__LIBINT -D__LIBXC -D__SCALAPACK -D__COSMA -D__OFFLOAD_GEMM   -D__SPLA   -D__HIP_PLATFORM_AMD__ -D__OFFLOAD_HIP -D__DBCSR_ACC -D__NO_OFFLOAD_PW" >> ${CP2K_DIR}/arch/local_hip.psmp \
      && make realclean ARCH=local_hip VERSION=psmp \
      && make -j 8 ARCH=local_hip VERSION=psmp \
      && cp ${CP2K_DIR}/exe/local_hip/cp2k.psmp ${CP2K_DIR}/exe/local_hip/cp2k.psmp.no_pw_gpu \
      && chmod -R 777 /opt/cp2k \
      && ln -s /opt/cp2k/exe/local_hip/ /opt/cp2k/bin \
      && mkdir /tmp/benchmarks 

COPY /scripts /scripts

RUN chmod -R 777 /scripts

# Adding environment variable for Running as ROOT
ENV PATH=$PATH:/opt/cp2k/bin:/scripts \
    OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx \
    OMPI_MCA_pml_ucx_tls=any \
    OMPI_MCA_osc=ucx \
    OMPI_MCA_btl=^vader,tcp,uct \
    OMPI_MCA_pml_ucx_devices=any \
    UCX_WARN_UNUSED_ENV_VARS=n \
    UCX_TLS=self,sm,tcp,rocm

WORKDIR /opt/cp2k/benchmarks

CMD ["/bin/bash"]

