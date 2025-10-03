ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG QMP_BRANCH="devel"
ARG QIO_BRANCH="master"
ARG QDPXX_BRANCH="devel"
ARG QUDA_BRANCH="develop"
ARG CHROMA_BRANCH="devel"

# Update and Install basic Linux development tools
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xmldiff \
  && apt-get clean

# Adding OpenMPI and UCX to Environment
ENV LLVN_DIR=${ROCM_PATH}/llvm/lib/cmake/llvm \
    LLD_DIR=${ROCM_PATH}/llvm/lib/cmake/lld \
    OMPI_CC=hipcc \
    OMPI_CXX=hipcc \
    MPICC=$OMPI_PATH/bin/mpicc \
    MPICXX=$OMPI_PATH/bin/mpic++ \
    MPIF77=$OMPI_PATH/bin/mpif77 \
    MPIF90=$OMPI_PATH/bin/mpif90 \
    INSTALLROOT=/opt

WORKDIR /tmp

#qmp
RUN git clone -b ${QMP_BRANCH} --recursive https://github.com/usqcd-software/qmp.git \
        && cd qmp \
        && mkdir build \
        && cd build \
        && cmake .. \
            -DQMP_MPI=ON \
            -DCMAKE_BUILD_TYPE=Release \
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
        PKG_CONFIG_PATH=${INSTALLROOT}/qmp/lib/pkgconfig:$PKG_CONFIG_PATH

#qio
RUN git clone -b ${QIO_BRANCH} --recursive https://github.com/usqcd-software/qio.git \
        && cd qio \
        && mkdir build \
        && cd build \
        && cmake .. \
            -D CMAKE_BUILD_TYPE=RELEASE \
            -D BUILD_SHARED_LIBS=ON \
            -D QIO_ENABLE_PARALLEL_BUILD=ON \
            -D QMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -D CMAKE_INSTALL_PREFIX=${INSTALLROOT}/qio \
        && make -j $(nproc) -v \
        && make install \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/qio/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/qio/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/qio/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/qio/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/qio/include:$CPLUS_INCLUDE_PATH \
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
        PKG_CONFIG_PATH=${INSTALLROOT}/qdpxx/lib/pkgconfig:$PKG_CONFIG_PATH

#quda
RUN git clone -b ${QUDA_BRANCH} --recursive https://github.com/lattice/quda.git \
        && cd quda \
        && find . -type f -name "*make" -exec sed -i "s/hipfft\/include/include\/hipfft/" {} \; \
        && mkdir build \
        && cd build \
        && cmake .. \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/quda \
            -DCMAKE_BUILD_TYPE=RELEASE \
            -DQUDA_TARGET_TYPE=HIP \
            -DQUDA_DIRAC_CLOVER=ON \
            -DQUDA_DOWNLOAD_EIGEN=ON \
            -DQUDA_GPU_ARCH=$AMDGPU_TARGETS \
            -DQUDA_QMP=ON \
            -DQMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -DQUDA_QIO=ON \
            -DQMP_DIR=${INSTALLROOT}/qio/lib/cmake/qio \
            -DQUDA_DIRAC_DEFAULT_OFF=ON \
            -DQUDA_DIRAC_STAGGERED=ON \
            -DCMAKE_CXX_COMPILER=mpicxx \
            -DCMAKE_C_COMPILER=mpicc \
            -DCMAKE_HIP_COMPILER=mpicxx \
            -DCMAKE_CXX_FLAGS="-O3 -ggdb --save-temps" \
            -DCMAKE_C_FLAGS="-O3 -ggdb --save-temps" \
            -DCMAKE_HIP_FLAGS="-O3 -ggdb --offload-arch=${AMDGPU_TARGETS} --save-temps" \
            -DCMAKE_SHARED_LINKER_FLAGS="-O3 -ggdb" \
            -DCMAKE_EXE_LINKER_FLAGS="-O3 -ggdb --offload-arch=${AMDGPU_TARGETS}" \
            -DCMAKE_HIP_ARCHITECTURES="${AMDGPU_TARGETS}" \
        && cmake --build . -v -j $(nproc) \
        && cmake --install . \
        && sed -i 's/\/opt\/rocm\/hipfft\/include/\/opt\/rocm\/include\/hipfft/'   /opt/quda/lib/cmake/QUDA/QUDATargets.cmake \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/quda/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/quda/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/quda/include:$CPLUS_INCLUDE_PATH \
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
        PKG_CONFIG_PATH=${INSTALLROOT}/chroma/lib/pkgconfig:$PKG_CONFIG_PATH \
        QUDA_ENABLE_P2P=0 \
        QUDA_ENABLE_GDR=0 \
        QUDA_RESOURCE_PATH=/tmp

WORKDIR /bench


CMD ["/bin/bash"]
