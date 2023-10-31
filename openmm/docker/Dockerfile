ARG IMAGE="rocm/dev-ubuntu-22.04:5.7-complete"

FROM ${IMAGE}

ARG OPENMM_BRANCH="8.0.0"
ARG OPENMMHIP_BRANCH="master"
ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"

RUN echo "gfx906"  > /opt/rocm/bin/target.lst \
    &&  echo "gfx908"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx90a"  >> /opt/rocm/bin/target.lst

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
    doxygen \
    python3-dev \
    swig \
    cython3 \
    python3-pip \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
    && pip3 install numpy scipy \
  && apt-get clean

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.27/cmake-3.27.7-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

ENV ROCM_PATH=/opt/rocm \
    UCX_PATH=/opt/ucx \
    OMPI_PATH=/opt/ompi \
    OPENMM_DIR=/opt/openmm 

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
          --with-rocm=/opt/rocm \
          --without-knem \
          --without-xpmem \
          --without-cuda \
          --enable-optimizations \
          --disable-logging \
          --disable-debug \
          --enable-assertions \
          --enable-params-check \
          --disable-examples \
          --enable-mt \
    &&  make -j $(nproc) \
    &&  make install

# Install OpenMPI
RUN cd /tmp \
    && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
    && cd ompi \
    && ./autogen.pl \
    && mkdir build \
    && cd build \
    && ../configure --prefix=$OMPI_PATH --with-ucx=$UCX_PATH \
        --enable-mca-no-build=btl-uct \
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
    PKG_CONFIG_PATH=$OMPI_PATH/lib/pkgconfig:$UCX_PATH/lib/pkgconfig:$PKG_CONFIG_PATH \
    OPENMM_DIR=/opt/openmm \
    OPENMM_FFT_BACKEND=1

# Installing OpenMM
RUN git clone -b ${OPENMM_BRANCH} https://github.com/openmm/openmm.git \
  && cd openmm \
  && mkdir build install \
  && cd build \
  && cmake .. \
    -D CMAKE_INSTALL_PREFIX=$OPENMM_DIR \
    -D OPENMM_BUILD_OPENCL_LIB=off \
    -D OPENMM_BUILD_COMMON=ON \
  && make -j 8 \
  && make install \
  && make PythonInstall \
  && chmod -R 777 ../build

ENV PATH=$OPENMM_DIR/bin:$PATH \
    LD_LIBRARY_PATH=$OPENMM_DIR/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OPENMM_DIR/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OPENMM_DIR/include:$OPENMM_DIR/platforms/common/include/:$OPENMM_DIR/openmmapi/include/:$OPENMM_DIR/libraries/lepton/include/:$OPENMM_DIR/include/openmm/reference/:$OPENMM_DIR/:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OPENMM_DIR/include:$OPENMM_DIR/platforms/common/include/:$OPENMM_DIR/openmmapi/include/:$OPENMM_DIR/libraries/lepton/include/:$OPENMM_DIR/include/openmm/reference/:$OPENMM_DIR/:$CPLUS_INCLUDE_PATH \
    CPATH=$OPENMM_DIR/include:$OPENMM_DIR/platforms/common/include/:$OPENMM_DIR/openmmapi/include/:$OPENMM_DIR/libraries/lepton/include/:$OPENMM_DIR/include/openmm/reference/:$OPENMM_DIR/:$CPATH \
    INCLUDE=$OPENMM_DIR/include:$OPENMM_DIR/platforms/common/include/:$OPENMM_DIR/openmmapi/include/:$OPENMM_DIR/libraries/lepton/include/:$OPENMM_DIR/include/openmm/reference/:$OPENMM_DIR/:$INCLUDE \
    PKG_CONFIG_PATH=$OPENMM_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

RUN git clone -b ${OPENMMHIP_BRANCH} https://github.com/amd/openmm-hip.git \
    && cd openmm-hip \
    && mkdir build \
    && cd build \
    && cmake .. \
      -D OPENMM_DIR=$OPENMM_DIR\
      -D CMAKE_INSTALL_PREFIX=$OPENMM_DIR\
      -D OPENMM_SOURCE_DIR=/tmp/openmm \
    && make -j 8 \
    && make install \
    && chmod -R 777 $OPENMM_DIR

WORKDIR /opt/openmm/examples/

# Adding environment variable for Running as ROOT and set MCA pml to UCX
ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx \
    OMPI_MCA_osc=ucx \
    OMPI_MCA_pml_ucx_tls=any \
    OMPI_MCA_pml_ucx_devices=any \
    OMPI_MCA_pml_ucx_verbose=100

CMD ["/bin/bash"]

