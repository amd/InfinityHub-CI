ARG IMAGE=rocm/dev-ubuntu-22.04:5.6-complete

FROM ${IMAGE}

ARG KOKKOS_VERSION=4.0.01
ARG ENABLE_OPENMP=Off
ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        make \
        gcc \
        g++ \
        nano \
        vim \
        wget \
        ca-certificates \
        git \
        libtinfo* \
        numactl \
        wget \
        tmux \
        autoconf \
        automake \
        libtool \
        pkg-config \
        libnuma* \
        gfortran \
        flex \
        hwloc \
        apt-utils \
        gnupg
RUN mkdir -p /opt/cmake \
    && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.23/cmake-3.23.0-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

# Adding rocm/cmake to the PATH
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
    INCLUDE=$ROCM_PATH/include:$INCLUDE \
    HSA_XNACK=1 

WORKDIR /tmp

# Install UCX
RUN cd /tmp/ \
    && git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
    && cd ucx \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && ../contrib/configure-release --prefix=$UCX_HOME \
          --with-rocm=/opt/rocm --without-knem \
          --without-xpmem  --without-cuda \
          --enable-optimizations  \
          --disable-logging \
          --disable-debug \
          --enable-assertions \
          --enable-params-check \
          --disable-examples \
    && make -j 8  \
    && make  install \
    && cd /tmp \
    && rm -rf *  

# Install OpenMPI
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --help \
    && ../configure --prefix=$OMPI_HOME --with-ucx=$UCX_HOME \
          --enable-mca-no-build=btl-uct  \
          --enable-mpi-f90 \
          --enable-mpi-c \
          --with-pmix=internal \
          --enable-mpi \
          --enable-mpi-fortran=yes \
          --disable-debug \
    && make -j 8 \
    && make install \
    && cd /tmp \
    && rm -rf *

ENV PATH=$OMPI_HOME/bin:$UCX_HOME/bin:$PATH \
    LD_LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$CPLUS_INCLUDE_PATH \
    CPATH=$OMPI_HOME/include:$UCX_HOME/include:$CPATH \
    INCLUDE=$OMPI_HOME/include:$UCX_HOME/include:$INCLUDE \
    PKG_CONFIG_PATH=$OMPI_HOME/lib/pkgconfig:$UCX_HOME/lib/pkgconfig:$PKG_CONFIG_PATH

RUN git clone https://github.com/google/benchmark.git \
    && cd benchmark \
    && mkdir build \
    && cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release -S . \
    && cmake --build . --config Release --target install

WORKDIR /

# Building and installing Kokkos
RUN git clone -b ${KOKKOS_VERSION} https://github.com/kokkos/kokkos.git \
        && cd kokkos \
        && mkdir build \
        && cd build \
        && if [ "$ENABLE_OPENMP" = "On" ]; then \
            cmake .. \
                -DCMAKE_BUILD_TYPE=Debug \
                -DCMAKE_CXX_COMPILER=amdclang++ \
                -DCMAKE_INSTALL_PREFIX=/opt/kokkos \
                -DCMAKE_INSTALL_PREFIX=/opt/kokkos \
                -DKokkos_ENABLE_BENCHMARKS=On \
                -DKokkos_ENABLE_HIP=On \
                -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=On \
                -DKokkos_ENABLE_TESTS=On \
                -DKokkos_ARCH_VEGA90A=On; \
                -DKokkos_ENABLE_OPENMP=${ENABLE_OPENMP} \
                -DKokkos_ENABLE_OPENMPTARGET=${ENABLE_OPENMP}; \
        else \
            cmake .. \
                -DCMAKE_BUILD_TYPE=Debug \
                -DCMAKE_CXX_COMPILER=hipcc \
                -DCMAKE_INSTALL_PREFIX=/opt/kokkos \
                -DKokkos_ENABLE_BENCHMARKS=On \
                -DKokkos_ENABLE_HIP=On \
                -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=On \
                -DKokkos_ENABLE_TESTS=On \
                -DKokkos_ARCH_VEGA90A=On; \
        fi \
        && make -j $(nproc)\
        && make install \
        && chmod -R a+rwx /kokkos

WORKDIR /kokkos/build

#Adding Kokkos, libs, and headers to Environment
ENV PATH=$PATH:/opt/kokkos/bin \
    LD_LIBRARY_PATH=/opt/kokkos/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/opt/kokkos/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=/opt/kokkos/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=/opt/kokkos/include:$CPLUS_INCLUDE_PATH \
    CPATH=/opt/kokkos/include:$CPATH \
    INCLUDE=/opt/kokkos/include


# Add any Build instructions that uses Kokkos Below. 


CMD [ "/bin/bash", "-c"]
