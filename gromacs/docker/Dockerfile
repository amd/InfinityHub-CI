ARG IMAGE="rocm/dev-ubuntu-22.04:6.0-complete"

FROM ${IMAGE}

ARG GROMACS_BRANCH="develop_2023_amd_sprint_rocm6"
ARG MPI_ENABLED="off"
ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"

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
    libfftw3-dev \
    kmod \
    python3 \
    libomp-dev \
    rocfft \
    tar \
  && apt-get clean

RUN echo "gfx906"  > /opt/rocm/bin/target.lst \
    &&  echo "gfx908"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx90a"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx942"  >> /opt/rocm/bin/target.lst

# Requires cmake > 3.27 
RUN mkdir -p /opt/cmake  \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.27/cmake-3.27.7-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

ENV ROCM_PATH=/opt/rocm \
    UCX_HOME=/opt/ucx \
    OMPI_HOME=/opt/ompi

# Adding rocm/cmake to the PATH
ENV PATH=$ROCM_PATH/bin:$ROCM_PATH/profiler/bin:$ROCM_PATH/opencl/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:$ROCM_PATH/libs/hipblas:$ROCM_PATH/libs/hipfft:$ROCM_PATH/libs/rocfft:$ROCM_PATH/libs/rocblas:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/libs/rocfft:$ROCM_PATH/libs/hipblas:$ROCM_PATH/libs/rocblas:$LIBRARY_PATH \
    C_INCLUDE_PATH=$ROCM_PATH/include:$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/rocblas:$ROCM_PATH/roctracer/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/rocblas:$ROCM_PATH/roctracer/include:$CPLUS_INCLUDE_PATH \
    CPATH=$ROCM_PATH/include:$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/rocblas:$ROCM_PATH/roctracer/include:$CPATH \
    INCLUDE=$ROCM_PATH/include:$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/rocblas:$ROCM_PATH/roctracer/include:$INCLUDE \
    CMAKE_PREFIX_PATH=$ROCM_PATH/lib/cmake:$CMAKE_PREFIX_PATH

WORKDIR /tmp

# Install UCX
RUN if [ "$MPI_ENABLED" = "on" ]; then \
      cd /tmp/ \
      && git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
      && cd ucx \
      && ./autogen.sh \
      && mkdir build \
      && cd build \
      && ../contrib/configure-release --prefix=$UCX_PATH \
            --with-rocm=/opt/rocm --without-knem \
            --without-xpmem  --without-cuda \
            --enable-optimizations  \
            --disable-logging \
            --disable-debug \
            --enable-assertions \
            --enable-params-check \
            --disable-examples \
      && make -j $(nproc)  \
      && make  install \
    else \
      echo "UCX was not installed"; \
    fi

# Install OpenMPI
RUN if [ "$MPI_ENABLED" = "on" ] ; then \
      cd /tmp \
      && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
      && cd ompi \
      && ./autogen.pl \
      && mkdir build \
      && cd build \
      && ../configure --prefix=$OMPI_HOME --with-ucx=$UCX_PATH \
            --enable-mca-no-build=btl-uct  \
            --with-pmix=internal \
            --enable-mpi \
            --enable-mpi-fortran=yes \
            --disable-debug \
      && make -j $(nproc) \
      && make install \
    else \
      echo "MPI was not installed"; \
    fi

# Adding OpenMPI and UCX to PATH
ENV PATH=$OMPI_HOME/bin:$UCX_PATH/bin:$PATH \
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROCM_PATH/lib

# Installing Gromnacs - HIP
RUN git clone -b ${GROMACS_BRANCH} https://github.com/ROCmSoftwarePlatform/Gromacs.git \
  && cd Gromacs \
  && mkdir build  \
  && cd build   \
  && cmake -DBUILD_SHARED_LIBS=off \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_FLAGS="-Ofast -ggdb " \
        -DCMAKE_CXX_FLAGS="-Ofast -ggdb " \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DGMX_BUILD_FOR_COVERAGE=off \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DGMX_MPI=${OMPI_ENABLED} \
        -DGMX_GPU=HIP \
        -DGMX_OPENMP=on \
        -DCMAKE_HIP_ARCHITECTURES="gfx900,gfx906,gfx908,gfx90a,gfx942" \
        -DGMX_SIMD=AVX2_256 \
        -DREGRESSIONTEST_DOWNLOAD=OFF \
        -DBUILD_TESTING=ON \
        -DGMXBUILD_UNITTESTS=ON \
        -DGMX_GPU_USE_VKFFT=on \
        -DHIP_HIPCC_FLAGS="-O3 -ggdb --amdgpu-target=gfx900,gfx906,gfx908,gfx90a,gfx942" \
        -DCMAKE_EXE_LINKER_FLAGS=" -fopenmp" \
      .. \
  && make -j $(nproc) \
  && make install \
  && rm -rf /tmp/*

COPY benchmark /benchmarks
RUN chmod -R g+w,o+w /benchmarks

# Adding environment variable for Running as ROOT and set MCA pml to UCX
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    GMX_GPU_DD_COMMS=1 \
    GMX_GPU_PME_PP_COMMS=1 \
    GMX_FORCE_UPDATE_DEFAULT_GPU=1 \
    ROC_ACTIVE_WAIT_TIMEOUT=0 \
    AMD_DIRECT_DISPATCH=1 \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/gromacs/lib/ \
    PATH=/benchmarks/:/usr/local/gromacs/bin:$PATH

# GPL -- need to include link to source code
RUN echo "echo Gromacs - HIP  source code located at https://github.com/ROCmSoftwarePlatform/Gromacs.git " >> /etc/profile.d/gromacs.sh

CMD ["/bin/bash"]

