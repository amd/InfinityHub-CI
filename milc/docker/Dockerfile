ARG IMAGE="rocm_gpu:5.6"

FROM ${IMAGE}

ARG QMP_BRANCH="devel"
ARG QIO_BRANCH="master"
ARG QUDA_BRANCH="develop"
ARG MILC_BRANCH="develop"

# Update and Install basic Linux development tools
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libxml2-dev \
  && apt-get clean
ENV LLVN_DIR=${ROCM_PATH}/llvm/lib/cmake/llvm \
    LLD_DIR=${ROCM_PATH}/llvm/lib/cmake/lld

WORKDIR /tmp

ENV OMPI_CC=hipcc \
    OMPI_CXX=hipcc \
    MPICC=$OMPI_PATH/bin/mpicc \
    MPICXX=$OMPI_PATH/bin/mpic++ \
    MPIF77=$OMPI_PATH/bin/mpif77 \
    MPIF90=$OMPI_PATH/bin/mpif90 \
    INSTALLROOT=/opt


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
            -DQUDA_TARGET_TYPE="HIP" \
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
            -DQUDA_GPU_ARCH="$GPU_TARGET" \
            -DGPU_ARCH="$GPU_TARGET" \
            -DQUDA_QMP=ON \
            -DQMP_DIR=${INSTALLROOT}/qmp/lib/cmake/QMP \
            -DQUDA_OPENMP=OFF \
            -DQUDA_MULTIGRID=OFF \
            -DQUDA_MAX_MULTI_BLAS_N=9 \
            -DQUDA_DOWNLOAD_EIGEN=ON \
            -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}/quda \
            -DCMAKE_BUILD_TYPE="RELEASE" \
            -DCMAKE_CXX_COMPILER="mpicxx"\
            -DCMAKE_C_COMPILER="mpicc" \
            -DBUILD_SHARED_LIBS=ON \
            -DQUDA_BUILD_SHAREDLIB=ON \
            -DQUDA_BUILD_ALL_TESTS=ON \
            -DCMAKE_CXX_STANDARD=17 \
            -DCMAKE_C_STANDARD=99 \
            -DQUDA_CTEST_DISABLE_BENCHMARKS=ON \
            -DQUDA_ENABLE_P2P=ON \
            -DCMAKE_C_FLAGS="--save-temps" \
            -DCMAKE_CXX_FLAGS="--save-temps" \
        && cmake --build . -v -j 8 \
        && cmake --install . \
        && rm -rf /tmp/*

ENV PATH=${INSTALLROOT}/quda/bin:$PATH \
        LD_LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LD_LIBRARY_PATH \
        LIBRARY_PATH=${INSTALLROOT}/quda/lib:$LIBRARY_PATH \
        C_INCLUDE_PATH=${INSTALLROOT}/quda/include:$C_INCLUDE_PATH \
        CPLUS_INCLUDE_PATH=${INSTALLROOT}/quda/include:$CPLUS_INCLUDE_PATH \
        PKG_CONFIG_PATH=${INSTALLROOT}/quda/lib/pkgconfig:$PKG_CONFIG_PATH

#milc
COPY Makefile.patch /tmp/
SHELL [ "/bin/bash", "-c" ]

RUN git clone -b ${MILC_BRANCH} --recursive https://github.com/milc-qcd/milc_qcd.git
RUN cd milc_qcd \
        && patch -u Makefile -i ../Makefile.patch \
        && cd ks_imp_rhmc \
        && cp ../Makefile . \
        && echo """fermion_force_asqtad_gpu.o: ../generic_ks/fermion_force_asqtad_gpu.c \
        \${CC} -c \${CFLAGS} \$< """ >> ../generic_ks/Make_template<<EOF \
        && mkdir -p /opt/milc/bin \
        && MY_CC=mpicc \
            MY_CXX=mpicxx \
            ARCH="mi200" \
            COMPILER="rocm" \
            OPT="-O3" \
            SCIDAC=${INSTALLROOT} \
            CUDA_HOME="" \
            QUDA_HOME=${INSTALLROOT}/quda \
            WANTQUDA=true \
            WANT_FN_CG_GPU=true \
            WANT_FL_GPU=true \
            WANT_GF_GPU=true \
            WANT_FF_GPU=true \
            QMPSNG=${INSTALLROOT}/qmp \
            QIOSNG=${INSTALLROOT}/qio \
            WANT_MIXED_PRECISION_GPU=2 \
            PRECISION=1 \
            MPP=true \
            OMP=true \
            WANTQIO=true \
            WANTQMP=true \
            QIOPAR=${INSTALLROOT}/qio \
            QMPPAR=${INSTALLROOT}/qmp \
            CGEOM="-DFIX_NODE_GEOM -DFIX_IONODE_GEOM" \
            KSCGMULTI="-DKS_MULTICG=HYBRID -DMULTISOURCE -DMULTIGRID" \
            CTIME="-DNERSC_TIME -DCGTIME -DFFTIME -DFLTIME -DGFTIME -DREMAP -DPRTIME -DIOTIME" \
            make -j 1 su3_rhmd_hisq \
        && ls \
        && cp ./su3_rhmd_hisq /opt/milc/bin/. \
        && rm -rf /tmp/*


COPY benchmarks /benchmark

WORKDIR /benchmark

RUN wget --quiet https://portal.nersc.gov/project/m888/apex/MILC_lattices/36x36x36x72.chklat \
        && chmod -R +wrx /benchmark

# Adding Milc to PATH
ENV PATH=${INSTALLROOT}/milc/bin:$PATH \
        QUDA_ENABLE_P2P=0 \
        QUDA_ENABLE_GDR=1 \
        QUDA_MILC_HISQ_RECONSTRUCT=13 \
        QUDA_MILC_HISQ_RECONSTRUCT_SLOPPY=9 \
        QUDA_RESOURCE_PATH=/tmp/

CMD ["/bin/bash"]
