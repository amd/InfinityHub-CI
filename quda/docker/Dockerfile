ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG QUDA_BRANCH="develop"
ARG QMP_BRANCH="devel"
ARG QIO_BRANCH="master"

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
        PKG_CONFIG_PATH=${INSTALLROOT}/qio/lib/pkgconfig:$PKG_CONFIG_PATH

#quda
RUN git clone -b ${QUDA_BRANCH} --recursive https://github.com/lattice/quda.git \
        && cd quda \
        && mkdir build \
        && cd build \
        && cmake /tmp/quda \
            -G "Unix Makefiles" \
            -DQUDA_TARGET_TYPE=HIP \
            -DQUDA_GPU_ARCH="$AMDGPU_TARGETS" \
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
            -DQUDA_ENABLE_P2P=ON \
            -DQUDA_QMP=ON \
            -DQMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -DQUDA_OPENMP=OFF \
            -DQUDA_MULTIGRID=ON \
            -DQUDA_MAX_MULTI_BLAS_N=9 \
            -DQUDA_DOWNLOAD_EIGEN=ON \
            -DQUDA_PRECISION=8 \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/quda \
            -DCMAKE_BUILD_TYPE=RELEASE \
            -DCMAKE_CXX_COMPILER=mpicxx\
            -DCMAKE_C_COMPILER=mpicc \
            -DCMAKE_HIP_COMPILER=mpicxx \
            -DBUILD_SHARED_LIBS=ON \
            -DQUDA_BUILD_SHAREDLIB=ON \
            -DQUDA_BUILD_ALL_TESTS=ON \
            -DQUDA_CTEST_DISABLE_BENCHMARKS=ON \
            -DCMAKE_CXX_STANDARD=17 \
            -DCMAKE_C_STANDARD=99 \
            -DCMAKE_CXX_FLAGS="-O3 -ggdb" \
            -DCMAKE_C_FLAGS="-O3 -ggdb" \
            -DCMAKE_HIP_FLAGS="-O3 -ggdb --offload-arch=${AMDGPU_TARGETS} --gpu-max-threads-per-block=1024" \
            -DCMAKE_SHARED_LINKER_FLAGS="-O3 -ggdb" \
            -DCMAKE_EXE_LINKER_FLAGS="-O3 -ggdb --offload-arch=${AMDGPU_TARGETS}" \
        && cmake --build . -v -j $(nproc) \
        && cmake --install . \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/quda/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/quda/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/quda/include:$CPLUS_INCLUDE_PATH \
        PKG_CONFIG_PATH=${INSTALLROOT}/quda/lib/pkgconfig:$PKG_CONFIG_PATH

# Adding Milc to PATH
ENV QUDA_ENABLE_P2P=0 \
    QUDA_ENABLE_GDR=1 \
    QUDA_RESOURCE_PATH=/tmp/

CMD ["/bin/bash"]

