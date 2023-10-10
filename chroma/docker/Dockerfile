ARG IMAGE="rocm/dev-ubuntu-22.04:5.6-complete"

FROM ${IMAGE}

ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"
ARG QMP_BRANCH="devel"
ARG QIO_BRANCH="master"
ARG QDPXX_BRANCH="devel"
ARG QUDA_BRANCH="develop"
ARG CHROMA_BRANCH="devel"
ARG GPU_TARGET="gfx90a"

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
    hwloc \
    libxml2-dev \
    python3 \
    unzip \
    xmldiff \
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
        OMPI_CC=hipcc \
        OMPI_CXX=hipcc \
        MPICC=$OMPI_PATH/bin/mpicc \
        MPICXX=$OMPI_PATH/bin/mpic++ \
        MPIF77=$OMPI_PATH/bin/mpif77 \
        MPIF90=$OMPI_PATH/bin/mpif90 \
        INSTALLROOT=/opt


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

#qdpxx
RUN git clone --recursive -b ${QDPXX_BRANCH} https://github.com/usqcd-software/qdpxx.git \
        && cd qdpxx \
        && git submodule update --recursive  \
        && mkdir build \
        && cd build \
        && cmake .. \
            -DQDP_PARALLEL_ARCH=parscalar \
            -DQDP_PRECISION=single \
            -DCMAKE_BUILD_Type=Release \
            -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_CXX_COMPILER=mpicxx \
            -DCMAKE_CXX_STANDARD=17 \
            -DCMAKE_CXX_EXTENSIONS=OFF \
            -DCMAKE_C_COMPILER=mpicc \
            -DCMAKE_C_STANDARD=99 \
            -DCMAKE_C_EXTENSIONS=ON \
            -DCMAKE_C_STANDARD_REQUIRED=TRUE \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/qdpxx \
            -DQMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
        && cmake --build . -j 8 -v \
        && cmake --install . \
        && rm -rf /tmp/*


ENV PATH=${INSTALLROOT}/qdpxx/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/qdpxx/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/qdpxx/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/qdpxx/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/qdpxx/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/qdpxx/include:$CPATH \
        INCLUDE=${INSTALLROOT}/qdpxx/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/qdpxx/lib/pkgconfig:$PKG_CONFIG_PATH

#quda
RUN git clone -b ${QUDA_BRANCH} --recursive https://github.com/lattice/quda.git \
        && cd quda \
        && mkdir build \
        && cd build \
        && cmake /tmp/quda \
            -G "Unix Makefiles" \
            -DQUDA_TARGET_TYPE="HIP" \
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
            -DQUDA_GPU_ARCH="$GPU_TARGET" \
            -DGPU_ARCH="$GPU_TARGET" \
            -DQUDA_QMP=ON \
            -DQMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -DQUDA_OPENMP=OFF \
            -DQUDA_MULTIGRID=OFF \
            -DQUDA_MAX_MULTI_BLAS_N=9 \
            -DQUDA_DOWNLOAD_EIGEN=ON \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/quda \
            -DCMAKE_BUILD_TYPE="RELEASE" \
            -DCMAKE_CXX_COMPILER="mpicxx"\
            -DCMAKE_C_COMPILER="mpicc" \
            -DBUILD_SHARED_LIBS=ON \
            -DQUDA_BUILD_SHAREDLIB=ON \
            -DQUDA_BUILD_ALL_TESTS=ON \
            -DCMAKE_CXX_STANDARD=17 \
            -DCMAKE_C_STANDARD=99 \
            -DQUDA_CTEST_DISABLE_BENCHMARKS=ON \
            -DQUDA_ENABLE_P2P=ON \
        && cmake --build . -v -j 8 \
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


#Chroma 
RUN git clone --recursive -b ${CHROMA_BRANCH} https://github.com/JeffersonLab/chroma.git \
        && cd chroma \
        && mkdir build \
        && cd build \
        && cmake .. \
            -DCMAKE_CXX_COMPILER=mpicxx \
            -DCMAKE_CXX_STANDARD=17 \
            -DCMAKE_CXX_EXTENSIONS=OFF  \
            -DCMAKE_C_COMPILER=mpicc \
            -DCMAKE_C_STANDARD=99 \
            -DCMAKE_C_EXTENSIONS=OFF  \
            -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_BUILD_TYPE=Release \
            -DQDPXX_DIR=${INSTALLROOT}/qdpxx/lib/cmake/QDPXX \
            -DQMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -DChroma_ENABLE_QUDA=ON \
            -DQUDA_DIR=${INSTALLROOT}/quda/lib/cmake/QUDA \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/chroma \
            -DCMAKE_Fortran_COMPILER=gfortran \
        &&  cmake --build . -j 8 \
        &&  cmake --install . \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/chroma/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/chroma/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/chroma/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/chroma/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/chroma/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/chroma/include:$CPATH \
        INCLUDE=${INSTALLROOT}/chroma/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/chroma/lib/pkgconfig:$PKG_CONFIG_PATH \
        QUDA_ENABLE_P2P=0 \
        QUDA_ENABLE_GDR=0 \
        QUDA_RESOURCE_PATH=/tmp/tuning


# Download benchmark
RUN wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1KmF32sM_Ts8uYMqj7eTPV4aeG0ZPEOyR' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p'))&id=1KmF32sM_Ts8uYMqj7eTPV4aeG0ZPEOyR" -O /szscl_bench.zip && rm -rf /tmp/cookies.txt \
        && unzip /szscl_bench.zip -d / \
        && rm /szscl_bench.zip \
        && chmod -R +x /bench

WORKDIR /bench

CMD ["/bin/bash"]
