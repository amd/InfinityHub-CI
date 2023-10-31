ARG IMAGE="rocm/dev-ubuntu-22.04:5.7-complete"

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
    libmpfr-dev \
    libelf1 \
    tar \
    libssl-dev \
    zlib1g-dev \
    python3 \
  && apt-get clean

# Note: only need to define the GFX arch that you are using
RUN echo "gfx900"      > /opt/rocm/bin/target.lst \
    &&  echo "gfx906"  >> /opt/rocm/bin/target.lst \ 
    &&  echo "gfx908"  >> /opt/rocm/bin/target.lst \       
    &&  echo "gfx90a"  >> /opt/rocm/bin/target.lst     
        
RUN chmod a+r /opt/rocm/bin/target.lst  

ENV ROCM_PATH=/opt/rocm
ENV HIP_PATH=$ROCM_PATH/hip \
    HCC_HOME=$ROCM_PATH/hcc

WORKDIR /tmp

# Install UCX
RUN cd /tmp/ \
      && echo git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
      && git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
      && ls -lsa  \
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
RUN cd /tmp \
      && echo git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
      && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
      && ls -lsa  \
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
ENV PATH=/opt/ompi/bin:/opt/ucx/bin:$PATH

#
# Build app
#
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
        LDFLAGS="-L${ROCM_PATH}/lib -L${ROCM_PATH}/roctracer/lib -lroctracer64 -lroctx64 -std=c++17" \
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
