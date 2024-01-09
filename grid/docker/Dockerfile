ARG IMAGE="rocm/dev-ubuntu-22.04:6.0-complete"

FROM ${IMAGE}

ARG GRID_BRANCH="develop"
ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"

RUN rm /etc/apt/sources.list.d/* \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    ssh \
    make \
    vim \
    nano \
    libtinfo-dev \
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
    libmpfr-dev \
    libelf1 \
    tar \
    libssl-dev \
    zlib1g-dev \
    python3 \
    libssl-dev \
  && apt-get clean


# Note: only need to define the GFX arch that you are using
RUN echo "gfx900"      > /opt/rocm/bin/target.lst \
    &&  echo "gfx906"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx908"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx90a"  >> /opt/rocm/bin/target.lst
        
RUN chmod a+r /opt/rocm/bin/target.lst  

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

#Install UCX
RUN git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
      && cd ucx \
      && ./autogen.sh \
      && mkdir build \
      && cd build \
      && ../contrib/configure-release --prefix=/opt/ucx \
            --with-rocm=$ROCM_PATH --without-knem \
            --without-xpmem --without-cuda \
            --enable-optimizations \
            --disable-logging \
            --disable-debug \
            --enable-assertions \
            --enable-params-check \
            --disable-examples \
      && make -j 8  \
      && make install \
      && cd /tmp \
      && rm -rf ucx

# Install OpenMPI
RUN git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
      && cd ompi \
      && ./autogen.pl\
      && mkdir build \
      && cd build \
      && ../configure --prefix=/opt/ompi --with-ucx=/opt/ucx \
            --enable-mca-no-build=btl-uct \
            --with-pmix=internal \
            --enable-mpi \
            --enable-mpi-fortran=yes \
            --disable-debug \
            --disable-man-pages \
      && make -j 8 \
      && make install \
      && cd /tmp \
      && rm -rf ompi

# Adding OpenMPI and UCX to PATH
ENV PATH=$OMPI_HOME/bin:$UCX_HOME/bin:$PATH \
    LD_LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OMPI_HOME/lib:$UCX_HOME/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OMPI_HOME/include:$UCX_HOME/include:$CPLUS_INCLUDE_PATH \
    CPATH=$OMPI_HOME/include:$UCX_HOME/include:$CPATH \
    INCLUDE=$OMPI_HOME/include:$UCX_HOME/include:$INCLUDE \
    PKG_CONFIG_PATH=$OMPI_HOME/lib/pkgconfig:$UCX_HOME/lib/pkgconfig:$PKG_CONFIG_PATH


#Build app

ENV GRID_PATH=/opt/grid

RUN git clone -b ${GRID_BRANCH} https://github.com/paboyle/Grid.git \
   && cd Grid \
   && ./bootstrap.sh \
   && mkdir build \
   && cd build \
   && ../configure \
        --prefix=$GRID_PATH \
        --enable-unified=no \
        --enable-accelerator=hip \
        --enable-setdevice \
        --enable-alloc-cache \
        --enable-shm=nvlink \
        --enable-comms=mpi3-auto \
        --enable-simd=GPU \
        --enable-gen-simd-width=64 \
        --disable-accelerator-cshift \
        --disable-fermion-reps \
        CXX=hipcc \
        MPICXX=mpicxx \
        CPPFLAGS="-I${ROCM_PATH}/include -I${ROCM_PATH}/include/roctracer -std=c++17 " \
        LDFLAGS="-L${ROCM_PATH}/lib -L${ROCM_PATH}/lib/roctracer -lroctracer64 -lroctx64 -std=c++17" \
   && make -j 8 \
   && make install \
   && cd /tmp \
   && rm -rf Grid

COPY ./benchmark $GRID_PATH/benchmark/.
RUN chmod a+rx  $GRID_PATH/benchmark/*.sh \
      && ln -s $GRID_PATH/benchmark/ /benchmark

WORKDIR /benchmark

ENV PATH=$GRID_PATH/bin:$PATH \
      OMPI_ALLOW_RUN_AS_ROOT=1 \
      OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
      OMPI_MCA_pml=ucx

CMD ["/bin/bash"]
