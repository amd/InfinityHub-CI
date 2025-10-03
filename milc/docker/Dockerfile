ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG QMP_BRANCH="master"
ARG QIO_BRANCH="master"
ARG QUDA_BRANCH="develop"
ARG MILC_BRANCH="develop"

ENV INSTALLROOT=/opt \
    MPI_CFLAGS="-I${OMPI_HOME}/include" \
    MPI_LDFLAGS="-L${OMPI_HOME}/lib -lmpi"

WORKDIR /tmp

#qmp
RUN git clone -b ${QMP_BRANCH} --recursive https://github.com/usqcd-software/qmp.git \
        && cd qmp \
        && mkdir build \
        && cd build \
        && cmake \
            -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_C_COMPILER=amdclang \
            -D CMAKE_CXX_COMPILER=amdclang++ \
            -D BUILD_SHARED_LIBS=ON \
            -D QMP_MPI=ON \
            -D CMAKE_INSTALL_PREFIX=${INSTALLROOT}/qmp \
            -D CMAKE_C_FLAGS="${MPI_CFLAGS}" \
            -D CMAKE_EXE_LINKER_FLAGS="${MPI_LDFLAGS}" \
            -D CMAKE_SHARED_LINKER_FLAGS="${MPI_LD_FLAGS}" \
            .. \
        && cmake --build . -j $(nproc) -v \
        && make install \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/qmp/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/qmp/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/qmp/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/qmp/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/qmp/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/qmp/include:$CPATH \
        INCLUDE=${INSTALLROOT}/qmp/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/qmp/lib/pkgconfig:$PKG_CONFIG_PATH

#qio
RUN git clone -b ${QIO_BRANCH} --recursive https://github.com/usqcd-software/qio.git \
        && cd qio \
        && mkdir build \
        && cd build \
        && cmake \
            -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_C_COMPILER=amdclang \
            -D CMAKE_CXX_COMPILER=amdclang++ \
            -D BUILD_SHARED_LIBS=ON \
            -D QIO_ENABLE_PARALLEL_BUILD=ON \
            -D QMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -D CMAKE_INSTALL_PREFIX=${INSTALLROOT}/qio  \
            -D CMAKE_C_FLAGS="${MPI_CFLAGS}" \
            -D CMAKE_EXE_LINKER_FLAGS="${MPI_LDFLAGS}" \
            -D CMAKE_SHARED_LINKER_FLAGS="${MPI_LD_FLAGS}" \
            .. \
        && make -j $(nproc) -v \
        && make install \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/qio/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/qio/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/qio/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/qio/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/qio/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/qio/include:$CPATH \
        INCLUDE=${INSTALLROOT}/qio/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/qio/lib/pkgconfig:$PKG_CONFIG_PATH

#quda
RUN git clone -b ${QUDA_BRANCH} --recursive https://github.com/lattice/quda.git \
        && cd quda \
        && mkdir build \
        && cd build \
        && cmake \
            -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_C_COMPILER=amdclang \
            -D CMAKE_CXX_COMPILER=amdclang++ \
            -D QUDA_TARGET_TYPE=HIP \
            -D QUDA_GPU_ARCH=$AMDGPU_TARGETS \
            -D QUDA_DIRAC_DEFAULT_OFF=ON \
            -D QUDA_DIRAC_STAGGERED=ON \
            -D QUDA_QMP=ON \
            -D QMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -D QUDA_QIO=ON \
            -D QIO_DIR=${INSTALLROOT}/qio/lib/cmake/QIO \
            -D CMAKE_INSTALL_PREFIX=${INSTALLROOT}/quda \
            -D CMAKE_C_FLAGS="${MPI_CFLAGS}" \
            -D CMAKE_CXX_FLAGS="${MPI_CFLAGS}" \
            -D CMAKE_EXE_LINKER_FLAGS="${MPI_LDFLAGS}" \
            -D CMAKE_SHARED_LINKER_FLAGS="${MPI_LD_FLAGS}" \
            .. \
        && cmake --build . -v -j $(nproc) \
        && cmake --install . \
        && rm -rf /tmp/* 

ENV PATH=${INSTALLROOT}/quda/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/quda/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/quda/include:$CPLUS_INCLUDE_PATH \
        CPATH=${INSTALLROOT}/quda/include:$CPATH \
        INCLUDE=${INSTALLROOT}/quda/include:$INCLUDE \
        PKG_CONFIG_PATH=${INSTALLROOT}/quda/lib/pkgconfig:$PKG_CONFIG_PATH

#milc
RUN git clone -b ${MILC_BRANCH} --recursive https://github.com/jakurzak/milc_qcd.git 
RUN cd milc_qcd \
        && mkdir -p /opt/milc/bin \
        && export COMPILER=amdclang \
                MY_CC=amdclang \
                MY_CXX=amdclang++ \
                OFFLOAD=HIP \
                WANT_MIXED_PRECISION_GPU=0 \
                PRECISION=1 \
                WANTQUDA=true \
                QUDA_HOME=${INSTALLROOT}/quda \
                WANTQIO=true \
                QIOPAR=${INSTALLROOT}/qio \
                WANTQMP=true \
                QMPPAR=${INSTALLROOT}/qmp \
                MPP=true \
                OMP=true \
                CGEOM="-DFIX_NODE_GEOM -DFIX_IONODE_GEOM" \
                KSCGMULTI="-DKS_MULTICG=HYBRID -DMULTISOURCE -DMULTIGRID" \
                CTIME="-DCGTIME -DFFTIME -DFLTIME -DGFTIME" \
                WANT_FN_CG_GPU=true \
                WANT_GF_GPU=true \
                WANT_GA_GPU=true \
                WANT_FL_GPU=true \
                WANT_FF_GPU=true \
                OCFLAGS="${OCFLAGS} ${MPI_CFLAGS}" \
                OCXXFLAGS="${OCXXFLAGS} ${MPI_CFLAGS}" \
                LDFLAGS="${LDFLAGS} ${MPI_LDFLAGS}" \
        && cd ks_imp_rhmc \
        && cp ../Makefile . \
        && make -j 1 su3_rhmd_hisq \
        && cp ./su3_rhmd_hisq /opt/milc/bin \
        && cd ../ks_spectrum \
        && cp ../Makefile . \
        && make -j 1 ks_spectrum_hisq \
        && cp ./ks_spectrum_hisq /opt/milc/bin \
        && rm -rf /tmp/*

WORKDIR /

RUN git clone https://gitlab.com/NERSC/N10-benchmarks/lattice-qcd-workflow /benchmark \
        && chmod -R 777 /benchmark

# Adding Milc to PATH
ENV PATH=${INSTALLROOT}/milc/bin:$PATH \
        OMP_NUM_THREADS=4 \
        QUDA_ENABLE_P2P=0 \
        QUDA_ENABLE_GDR=1 \
        QUDA_MILC_HISQ_RECONSTRUCT=13 \
        QUDA_MILC_HISQ_RECONSTRUCT_SLOPPY=9 \
        QUDA_RESOURCE_PATH=/tmp

CMD ["/bin/bash"]
