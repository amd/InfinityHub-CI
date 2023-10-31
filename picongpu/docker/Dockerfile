ARG IMAGE="rocm/dev-ubuntu-22.04:5.7-complete"

FROM ${IMAGE}

ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"
ARG PICONGPU_BRANCH="release-0.7.0"
ARG HDF5_BRANCH="hdf5-1_14_1"
ARG GPU_TARGET=gfx90a

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
    rsync \
    libpng-dev \
    libboost-program-options-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libboost-chrono-dev \
    libboost-atomic-dev \
    libboost-date-time-dev \
    libboost-math-dev \
    libboost-serialization-dev \
    libboost-fiber-dev \
    libboost-context-dev \
  && apt-get clean

RUN echo "${GPU_TARGET}"  >> /opt/rocm/bin/target.lst

# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.27/cmake-3.27.1-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

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
    INCLUDE=$ROCM_PATH/include:$INCLUDE \
    CMAKE_PREFIX_PATH=$ROCM_PATH:$CMAKE_PREFIX_PATH

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
    PKG_CONFIG_PATH=$OMPI_PATH/lib/pkgconfig:$UCX_PATH/lib/pkgconfig:$PKG_CONFIG_PATH \
    OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx \
    UCX_WARN_UNUSED_ENV_VARS=n

#pngwriter
RUN git clone https://github.com/pngwriter/pngwriter.git \
    && cd pngwriter \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/pngwriter .. \
    && make install

ENV LD_LIBRARY_PATH=/opt/pngwriter/lib \
        CMAKE_PREFIX_PATH=/opt/pngwriter:$CMAKE_PREFIX_PATH

RUN cd /tmp \
    && git clone --recursive https://github.com/HDFGroup/hdf5.git -b ${HDF5_BRANCH} \
    && cd hdf5 \
    && CC=mpicc \
        ./configure --prefix=$HDF5_HOME --enable-parallel \
    && make -j 16 \
    && make install \
    && cd /tmp \
    && rm -rf hdf5

ENV PATH=$HDF5_HOME/bin:$PATH \
    LD_LIBRARY_PATH=$HDF5_HOME/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$HDF5_HOME/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$HDF5_HOME/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$HDF5_HOME/include:$CPLUS_INCLUDE_PATH \
    CPATH=$HDF5_HOME/include:$CPATH \
    INCLUDE=$HDF5_HOME/include:$INCLUDE \
    PKG_CONFIG_PATH=$HDF5_HOME/lib/pkgconfig:$PKG_CONFIG_PATH    

RUN git clone https://github.com/openPMD/openPMD-api.git openpmd \
    && cd openpmd \
    && mkdir build \
    && cd build \
    && cmake .. -DopenPMD_USE_MPI=ON -DHDF5_ENABLE_PARALLEL=ON -DCMAKE_INSTALL_PREFIX=/opt/openpmd-api \
    && make -j $(nproc) install 

ENV CMAKE_PREFIX_PATH=/opt/openpmd-api:$CMAKE_PREFIX_PATH \
        LD_LIBRARY_PATH=/opt/openpmd-api/lib:$LD_LIBRARY_PATH \
        PICSRC=/opt/picongpu/

ENV PIC_EXAMPLES=$PICSRC/share/picongpu/examples \
        PATH=$PICSRC:$PICSRC/bin:$PICSRC/src/tools/bin:$PATH \
        PYTHONPATH=$PICSRC/lib/python:$PYTHONPATH \
        CXX=hipcc
WORKDIR /opt

#Build Picongpu
RUN git clone -b ${PICONGPU_BRANCH} https://github.com/ComputationalRadiationPhysics/picongpu.git \
    && mkdir -p picon-examples \
    && cd picon-examples \
    && pic-create $PICSRC/share/picongpu/tests/KHI_growthRate/ khi_fom \
    && cd khi_fom \
    && pic-build -f -b "hip:${GPU_TARGET}" \
    && chmod -R 777 /opt/picon-examples

WORKDIR /opt/picon-examples

CMD ["/bin/bash"]

