ARG IMAGE="rocm/dev-ubuntu-20.04:5.3.3-complete"

FROM ${IMAGE}
ARG PETSC_BRANCH="default"
ARG UCX_BRANCH="v1.13.0"
ARG OMPI_BRANCH="v5.0.0rc2"



# Update and Install basic Linux development tools
RUN apt-get update \
  && apt install -y --reinstall ca-certificates \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-utils \
    g++ \
    gfortran \
    git \
    ssh \
    make \
    vim \
    nano \
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
    libfftw3-dev \
    kmod \
    python3 \
    python3-distutils \
    libomp-7-dev \
    dos2unix \
    libopenblas-dev \
    libnuma-dev \
    libgmp-dev \
    libboost-all-dev \
    libmpfr-dev \
    bison \
    libelf1 \
    libtinfo* \
    initramfs-tools \
    rocm-hip-runtime \
    rocm-hip-sdk \
    rocm-llvm \
    rocm-hip-sdk \
    rocfft \
    hipfft \
    rocm-dev \
    rocm-libs \
    rccl


# Requires cmake > 3.22 
RUN mkdir -p /opt/cmake \
  && wget --no-check-certificate --quiet -O - https://cmake.org/files/v3.22/cmake-3.22.2-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /opt/cmake

# Adding rocm/cmake to the PATH
ENV ROCM_PATH=/opt/rocm
ENV HIP_PATH=$ROCM_PATH/hip \
      HCC_HOME=$ROCM_PATH/hcc
ENV PATH=$PATH:$HCC_HOME/bin:$HIP_PATH/bin:$ROCM_PATH/bin:$ROCM_PATH/profiler/bin:$ROCM_PATH/opencl/bin:/opt/cmake/bin:/opt/ompi/bin \
      LIBRARY_PATH=$LIBRARY_PATH:$ROCM_PATH/lib:$ROCM_PATH/llvm/lib:$ROCM_PATH/hip/lib:$ROCM_PATH/hsa/lib:$ROCM_PATH/lib64:/opt/openmm/lib \
      LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROCM_PATH/lib:$ROCM_PATH/llvm/lib:$ROCM_PATH/hip/lib:$ROCM_PATH/hsa/lib:$ROCM_PATH/lib64:/opt/openmm/lib \
      INCLUDE=$INCLUDE:$ROCM_PATH/include:$ROCM_PATH/llvm/include:$ROCM_PATH/hsa/include 

WORKDIR /tmp

# Install UCX
RUN cd /tmp/ \
      &&  git clone https://github.com/openucx/ucx.git -b ${UCX_BRANCH} \
      &&  cd ucx \
      &&  ./autogen.sh \
      &&  mkdir build \
      &&  cd build \
      &&  ../contrib/configure-release --prefix=/opt/ucx \
            --with-rocm=$ROCM_PATH --without-knem \
            --without-xpmem --without-cuda \
            --enable-optimizations \
            --disable-logging \
            --disable-debug \
            --enable-assertions \
            --enable-params-check \
            --disable-examples \
      &&  make -j 8 \
      &&  make install 

# Install OpenMPI
RUN cd /tmp \
      && git clone --recursive https://github.com/open-mpi/ompi.git -b ${OMPI_BRANCH} \
      && cd ompi \
      && ./autogen.pl \
      && mkdir build \
      && cd build \
      && ../configure --prefix=/opt/ompi --with-ucx=/opt/ucx \
           --enable-mca-no-build=btl-uct \
            --enable-mpi-f90 \
            --enable-mpi-c \
            --with-pmix CC=gcc \
            --enable-mpi \
            --enable-mpi-fortran=yes \
            --disable-debug \
            --disable-man-pages \
      && make -j 8 \
      && make install

# Adding OpenMPI and UCX to PATH
ENV PATH=/opt/ompi/bin:/opt/ucx/bin:$PATH

# Installing PETSc
RUN if [ "$PETSC_BRANCH" = "default" ]; then \
    # At time of creating this recipe, there are performance enhancements for PETSc that have not been incorporated in a release.
    git clone https://github.com/petsc/petsc.git \
    && cd petsc \
    && git checkout e874ec00d637a86419bb2cc912cf88b33e5547ef; \
  else \
    git clone -b ${PETSC_BRANCH} https://github.com/petsc/petsc.git \
    && cd petsc; \
  fi \
  && ./configure --with-cc=mpicc --with-cxx=mpicxx --with-fc=mpif90 \
         COPTFLAGS="-g -O3" FOPTFLAGS="-g -O3" CXXOPTFLAGS="-g -O3" HIPOPTFLAGS="-g -ggdb -O3 -munsafe-fp-atomics -fPIC -w" \
         --with-cuda=0 --with-hip=1 --with-hipc=hipcc --with-hip-dir=${ROCM_PATH} \
         --with-hip-arch=gfx900,gfx906,gfx908,gfx90a \
         --with-precision=double \
         --with-clanguage=c \
         --download-fblaslapack \
         --download-hypre \
         --download-hypre-configure-arguments=--enable-unified-memory \
         --with-debugging=no \
         --prefix=/opt/petsc \
  && make PETSC_DIR=/tmp/petsc PETSC_ARCH=arch-linux-c-opt all \
  && make PETSC_DIR=/tmp/petsc PETSC_ARCH=arch-linux-c-opt install \
  && make install \
  && rm -rf /tmp/*

COPY benchmark /opt/petsc
WORKDIR /opt/petsc
RUN chmod -R g+w,o+w /opt/petsc \
      && chmod a+rwx /opt/petsc/run-benchmark.sh \
      && ln -s /opt/petsc/share/petsc/examples/src src

# Adding environment variable for Running as ROOT and PETSc variables.
ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    PKG_CONFIG_PATH=/opt/petsc/lib/pkgconfig/ \
    PETSC_DIR=/opt/petsc \
    PETSC_ARCH=arch-linux-c-opt

CMD ["/bin/bash"]