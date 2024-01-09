ARG IMAGE="rocm/dev-ubuntu-22.04:5.7-complete"

FROM ${IMAGE}

ARG UCX_BRANCH="v1.14.1"
ARG OMPI_BRANCH="v4.1.5"
ARG OPENFOAM_VERSION="v2212"
ARG SCOTCH_VER="7.0.3"
ARG PETSC_VER="3.20.0"
ARG USE_HYPRE=TRUE

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
    libfl-dev \
    hwloc \
    libfftw3-dev \
    python3 \
    python3-distutils \
    libomp-dev \
    libopenblas-dev \
    libnuma-dev \
    libgmp-dev \
    libboost-all-dev \
    libmpfr-dev \
    bison \
    libelf1 \
    unzip \
    tar \
  && apt-get clean

ENV ROCM_PATH=/opt/rocm \
    UCX_HOME=/opt/ucx \
    OMPI_HOME=/opt/ompi

# Adding rocm to the Environment 
ENV PATH=$ROCM_PATH/bin:$ROCM_PATH/profiler/bin:/opt/cmake/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib \
    LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64 \
    C_INCLUDE_PATH=$ROCM_PATH/include:$ROCM_PATH/include/hipsparse \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$ROCM_PATH/include/hipsparse \
    CPATH=$ROCM_PATH/include:$ROCM_PATH/include/hipsparse \
    INCLUDE=$ROCM_PATH/include:$ROCM_PATH/include/hipsparse

# To reduce build time only use one
RUN echo "gfx900"      > /opt/rocm/bin/target.lst \
    &&  echo "gfx906"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx908"  >> /opt/rocm/bin/target.lst \
    &&  echo "gfx90a"  >> /opt/rocm/bin/target.lst

RUN chmod a+r /opt/rocm/bin/target.lst

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
    PKG_CONFIG_PATH=$OMPI_HOME/lib/pkgconfig:$UCX_HOME/lib/pkgconfig:$PKG_CONFIG_PATH

# Install Scotch, PETSc, then OpenFOAM
ENV OPENFOAM_DIR=/home/OpenFOAM/OpenFOAM-${OPENFOAM_VERSION} \
    THIRDPARTY_DIR=/home/OpenFOAM/ThirdParty-${OPENFOAM_VERSION} \
    WM_NCOMPPROCS=8
#RUN ./build.sh --prefix /home/OpenFOAM --openfoam-version ${OPENFOAM_VERSION} --clean

SHELL ["/bin/bash", "-c"]

WORKDIR /home/OpenFOAM/

RUN git clone -b OpenFOAM-${OPENFOAM_VERSION} https://develop.openfoam.com/Development/openfoam.git OpenFOAM-${OPENFOAM_VERSION}
RUN git clone -b ${OPENFOAM_VERSION} https://develop.openfoam.com/Development/ThirdParty-common.git ThirdParty-${OPENFOAM_VERSION}

COPY scripts/makePETSC.hip /home/OpenFOAM/ThirdParty-${OPENFOAM_VERSION}/makePETSC.hip
RUN chmod 777 /home/OpenFOAM/ThirdParty-${OPENFOAM_VERSION}/makePETSC.hip


RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && cd ThirdParty-${OPENFOAM_VERSION} \
    && git clone -b v${SCOTCH_VER} https://gitlab.inria.fr/scotch/scotch.git scotch_${SCOTCH_VER} \
    && sed -i -e "s|.*SCOTCH_VERSION=scotch_.*|SCOTCH_VERSION=scotch_${SCOTCH_VER}|g" ${OPENFOAM_DIR}/etc/config.sh/scotch \
    && ./Allwmake -q

# PETSc 3.18.1 and 3.18.2 have issues with GAMG and CUPM interface, but fixes already included in `main`
RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && cd ThirdParty-${OPENFOAM_VERSION} \
    && git clone -b v${PETSC_VER} https://gitlab.com/petsc/petsc.git petsc-${PETSC_VER} \
    && sed -i -e "s|petsc_version=petsc-.*|petsc_version=petsc-${PETSC_VER}|g" ${OPENFOAM_DIR}/etc/config.sh/petsc \
    && if [[ ${USE_HYPRE} ]] ; then \
        ./makePETSC.hip; \
    else \
        ./makePETSC.hip -no-hypre; \
    fi

RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && if $SHELL foamSystemCheck | grep -iq 'fail'; then \
        echo "foamSystemCheck failed" 1>&2 \
        && exit 1; \
    fi

 RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && echo ${WM_PROJECT_DIR} \
     && cd ${OPENFOAM_DIR} \
     && ./Allwmake -q -l

ENV PATH=${OPENFOAM_DIR}/bin:${OPENFOAM_DIR}/platforms/linux64GccDPInt32Opt/bin:$PATH \
    LD_LIBRARY_PATH=${OPENFOAM_DIR}/platforms/linux64GccDPInt32Opt/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=${OPENFOAM_DIR}/platforms/linux64GccDPInt32Opt/lib:$LIBRARY_PATH 


RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && cd ${OPENFOAM_DIR} \
    && git submodule update --init ${OPENFOAM_DIR}/modules/external-solver \
    && cd ${OPENFOAM_DIR}/modules/external-solver \
    && ./Allwmake -j -q -l \
    && mkdir /openfoam/ \
    && cp -r $(dirname $(find /root/ -iname libpetscFoam.so)) /openfoam

ENV PATH=${THIRDPARTY_DIR}/petsc-${PETSC_VER}/DPInt32/bin:${THIRDPARTY_DIR}/scotch_${SCOTCH_VER}/bin:$PATH \
    LD_LIBRARY_PATH=/openfoam/lib:${THIRDPARTY_DIR}/petsc-${PETSC_VER}/lib:${THIRDPARTY_DIR}/petsc-${PETSC_VER}/DPInt32/lib:${THIRDPARTY_DIR}/platforms/linux64GccDPInt32/lib:${THIRDPARTY_DIR}/platforms/linux64GccDPInt32/petsc-${PETSC_VER}/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/openfoam/lib:${THIRDPARTY_DIR}/petsc-${PETSC_VER}/lib:${THIRDPARTY_DIR}/petsc-${PETSC_VER}/DPInt32/lib:${THIRDPARTY_DIR}/platforms/linux64GccDPInt32/lib:${THIRDPARTY_DIR}/platforms/linux64GccDPInt32/petsc-${PETSC_VER}/lib:$LIBRARY_PATH

COPY /scripts /benchmark

WORKDIR /benchmark

RUN chmod -R 777 /benchmark \
    && ./load_benchmark.sh --prefix /benchmark \
    && chmod -R 777 /benchmark


# Adding environment variable for Running as ROOT
ENV OMPI_ALLOW_RUN_AS_ROOT=1  \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

CMD ["/bin/bash"]

