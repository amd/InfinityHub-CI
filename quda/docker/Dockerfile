ARG IMAGE="rocm/dev-ubuntu-22.04:6.0-complete"

FROM ${IMAGE}

ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"
ARG QUDA_BRANCH="develop"
ARG QMP_BRANCH="devel"
ARG QIO_BRANCH="master"
ARG GPU_TARGET="gfx908,gfx90a"

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
    libxml2-dev \
    python3 \
    unzip \
  && apt-get clean

RUN bash -c "IFS=',' read -r -a ARCH <<<${GPU_TARGET} \
    && for gpu_arch in \${ARCH[@]}; do \
       echo \$gpu_arch  >> /opt/rocm/bin/target.lst; \
    done \
    && chmod a+r /opt/rocm/bin/target.lst"

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.27/cmake-3.27.0-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

ENV ROCM_PATH=/opt/rocm \
    UCX_PATH=/opt/ucx \
    OMPI_PATH=/opt/ompi

# Adding rocm/cmake to the Environment 
ENV PATH=$ROCM_PATH/bin:$ROCM_PATH/profiler/bin:$ROCM_PATH/llvm/bin:$ROCM_PATH/opencl/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$LIBRARY_PATH \
    C_INCLUDE_PATH=$ROCM_PATH/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$CPLUS_INCLUDE_PATH \
    CPATH=$ROCM_PATH/include:$CPATH \
    INCLUDE=$ROCM_PATH/include:$INCLUDE \
    LLVN_DIR=${ROCM_PATH}/llvm/lib/cmake/llvm \
    LLD_DIR=${ROCM_PATH}/llvm/lib/cmake/lld

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
        && make install \
        && rm -rf /tmp/*

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
        && make install \
        && rm -rf /tmp/*

# Adding OpenMPI and UCX to Environment
ENV PATH=$OMPI_PATH/bin:$UCX_PATH/bin:$PATH \
        LD_LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=$OMPI_PATH/lib:$UCX_PATH/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=$OMPI_PATH/include:$UCX_PATH/include:$CPLUS_INCLUDE_PATH \
        CPATH=$OMPI_PATH/include:$UCX_PATH/include:$CPATH \
        INCLUDE=$OMPI_PATH/include:$UCX_PATH/include:$INCLUDE \
        PKG_CONFIG_PATH=$OMPI_PATH/lib/pkgconfig:$UCX_PATH/lib/pkgconfig:$PKG_CONFIG_PATH \ 
        OMPI_ALLOW_RUN_AS_ROOT=1  \
        OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
        UCX_WARN_UNUSED_ENV_VARS=n \
        OMPI_MCA_pml=ucx \
        OMPI_CC=hipcc \
        OMPI_CXX=hipcc \
        MPICC=$OMPI_PATH/bin/mpicc \
        MPICXX=$OMPI_PATH/bin/mpic++ \
        MPIF77=$OMPI_PATH/bin/mpif77 \
        MPIF90=$OMPI_PATH/bin/mpif90 \
        INSTALLROOT=/opt

# Install Additional Apps Below

#qmp

RUN git clone -b ${QMP_BRANCH} --recursive https://github.com/usqcd-software/qmp.git \
        && cd qmp \
        && mkdir build \
        && cd build \
        && cmake .. \
            -DQMP_MPI=ON \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_C_COMPILER=mpicc \
            -DCMAKE_C_STANDARD=99 \
            -DCMAKE_C_EXTENSIONS=OFF \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/qmp  \
            -DBUILD_SHARED_LIBS=ON \
        && cmake --build . -j $(nproc) -v \
        && make install \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/qmp/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/qmp/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/qmp/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/qmp/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/qmp/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/qmp/include:$CPATH \
        INCLUDE=${INSTALLROOT}/qmp/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/qmp/lib/pkgconfig:$PKG_CONFIG_PATH

#qio
RUN git clone -b ${QIO_BRANCH} --recursive https://github.com/usqcd-software/qio.git \
        && cd qio \
        && mkdir build \
        && ./autogen.sh \
        && cd build \
        && ../configure \
            CFLAGS=-std=gnu99 CC=mpicc CFLAGS=-std=gnu99 LDFLAGS=-lmpi \
            --prefix=${INSTALLROOT}/qio \
            -with-qmp=${INSTALLROOT}/qmp \
            --enable-largefile \
            --disable-qmp-route \
            --enable-fast_route \
            --enable-dml-output-buffering \
            --enable-dml-bufsize=33554432 \
        && make -j $(nproc) -v \
        && make install \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/qio/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/qio/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/qio/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/qio/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/qio/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/qio/include:$CPATH \
        INCLUDE=${INSTALLROOT}/qio/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/qio/lib/pkgconfig:$PKG_CONFIG_PATH

#quda
RUN git clone -b ${QUDA_BRANCH} --recursive https://github.com/lattice/quda.git \
        && cd quda \
        && mkdir build \
        && cd build \
        && cmake /tmp/quda \
            -G "Unix Makefiles" \
            -DQUDA_TARGET_TYPE=HIP \
            -DQUDA_GPU_ARCH="$GPU_TARGET" \
            -DROCM_PATH=${ROCM_PATH} \
            -DQUDA_DIRAC_CLOVER=ON \
            -DQUDA_DIRAC_CLOVER_HASENBUSCH=ON \
            -DQUDA_DIRAC_DOMAIN_WALL=ON \
            -DQUDA_DIRAC_NDEG_TWISTED_MASS=OFF \
            -DQUDA_DIRAC_STAGGERED=ON \
            -DQUDA_DIRAC_TWISTED_MASS=OFF \
            -DQUDA_DIRAC_TWISTED_CLOVER=OFF \
            -DQUDA_DIRAC_WILSON=ON \
            -DQUDA_DYNAMIC_CLOVER=OFF \
            -DQUDA_FORCE_GAUGE=ON \
            -DQUDA_FORCE_HISQ=ON \
            -DQUDA_GAUGE_ALG=ON \
            -DQUDA_GAUGE_TOOLS=OFF \
            -DQUDA_QDPJIT=OFF \
            -DQUDA_INTERFACE_QDPJIT=OFF \
            -DQUDA_INTERFACE_MILC=ON \
            -DQUDA_INTERFACE_CPS=OFF \
            -DQUDA_INTERFACE_QDP=ON \
            -DQUDA_INTERFACE_TIFR=OFF \
            -DQUDA_MAGMA=OFF \
            -DQUDA_ENABLE_P2P=ON \
            -DQUDA_QMP=ON \
            -DQMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -DQUDA_OPENMP=OFF \
            -DQUDA_MULTIGRID=ON \
            -DQUDA_MAX_MULTI_BLAS_N=9 \
            -DQUDA_DOWNLOAD_EIGEN=ON \
            -DQUDA_PRECISION=8 \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/quda \
            -DCMAKE_BUILD_TYPE=RELEASE \
            -DCMAKE_CXX_COMPILER=mpicxx\
            -DCMAKE_C_COMPILER=mpicc \
            -DCMAKE_HIP_COMPILER=mpicxx \
            -DBUILD_SHARED_LIBS=ON \
            -DQUDA_BUILD_SHAREDLIB=ON \
            -DQUDA_BUILD_ALL_TESTS=ON \
            -DQUDA_CTEST_DISABLE_BENCHMARKS=ON \
            -DCMAKE_CXX_STANDARD=17 \
            -DCMAKE_C_STANDARD=99 \
            -DCMAKE_CXX_FLAGS="-O3 -ggdb" \
            -DCMAKE_C_FLAGS="-O3 -ggdb" \
            -DCMAKE_HIP_FLAGS="-O3 -ggdb --offload-arch=${GPU_TARGET} --gpu-max-threads-per-block=1024" \
            -DCMAKE_SHARED_LINKER_FLAGS="-O3 -ggdb" \
            -DCMAKE_EXE_LINKER_FLAGS="-O3 -ggdb --offload-arch=${GPU_TARGET}" \
        && cmake --build . -v -j $(nproc) \
        && cmake --install . \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/quda/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/quda/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/quda/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/quda/include:$CPATH \
        INCLUDE=${INSTALLROOT}/quda/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/quda/lib/pkgconfig:$PKG_CONFIG_PATH

# Adding Milc to PATH
ENV QUDA_ENABLE_P2P=0 \
    QUDA_ENABLE_GDR=1 \
    QUDA_RESOURCE_PATH=/tmp/tuning

CMD ["/bin/bash"]

