ARG IMAGE="rocm_gpu:6.1.1"

FROM ${IMAGE}

ARG CP2K_BRANCH="v2024.1"
ARG GPU_VER="Mi250"

WORKDIR /tmp

ENV LD_LIBRARY_PATH=$ROCM_PATH/lib/hipblas:$ROCM_PATH/lib/hipfft:$ROCM_PATH/lib/rocfft:$ROCM_PATH/lib/rocblas:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ROCM_PATH/lib/rocfft:$ROCM_PATH/lib/hipblas:$ROCM_PATH/lib/rocblas:$LIBRARY_PATH \
    C_INCLUDE_PATH=$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/rocblas:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$ROCM_PATH/include/rocfft:$ROCM_PATH/include/hipfft:$ROCM_PATH/include/hipblas:$ROCM_PATH/include/rocblas:$CPLUS_INCLUDE_PATH \
    CP2K_DIR=/opt/cp2k

SHELL [ "/bin/bash", "-c" ]

WORKDIR /opt/    

# Get CP2K
RUN git clone --recursive -b ${CP2K_BRANCH} https://github.com/cp2k/cp2k.git \
      && cd cp2k/tools/toolchain \
      && ./install_cp2k_toolchain.sh \
            -j $(nproc) \
            --install-all \
            --mpi-mode=openmpi \
            --math-mode=openblas \
            --gpu-ver=${GPU_VER} \
            --enable-hip \
            --with-gcc=system \
            --with-openmpi=system \
            --with-mkl=no \
            --with-acml=no \
            --with-ptscotch=no \
            --with-superlu=no \
            --with-pexsi=no \
            --with-quip=no \
            --with-plumed=no \
            --with-sirius=no \
            --with-gsl=no \
            --with-libvdwxc=no \
            --with-spglib=no \
            --with-hdf5=no \
            --with-spfft=no \
            --with-libvori=no \
            --with-libtorch=no \
            --with-elpa=no \
        && sed -i 's/hip\/bin/bin/' /opt/cp2k/tools/toolchain/install/arch/local_hip.psmp \
        && cp ${CP2K_DIR}/tools/toolchain/install/arch/* ${CP2K_DIR}/arch \
        && sed -i 's/-D__DBCSR_ACC//' ${CP2K_DIR}/arch/local_hip.psmp \
        && cat ${CP2K_DIR}/arch/local_hip.psmp \
        && source ${CP2K_DIR}/tools/toolchain/install/setup \
        && cd ${CP2K_DIR}    \
        && make realclean ARCH=local_hip VERSION=psmp \
        && make -j $(nproc) ARCH=local_hip VERSION=psmp \
        && cp ${CP2K_DIR}/exe/local_hip/cp2k.psmp ${CP2K_DIR}/exe/local_hip/cp2k.psmp.no_dbcsr_gpu \
        && cp ${CP2K_DIR}/tools/toolchain/install/arch/* ${CP2K_DIR}/arch \
        && sed -i 's/-D__DBCSR_ACC/-D__DBCSR_ACC -D__NO_OFFLOAD_PW/' ${CP2K_DIR}/arch/local_hip.psmp \
        && make realclean ARCH=local_hip VERSION=psmp \
        && make -j $(nproc) ARCH=local_hip VERSION=psmp \
        && cp ${CP2K_DIR}/exe/local_hip/cp2k.psmp ${CP2K_DIR}/exe/local_hip/cp2k.psmp.no_pw_gpu \
        && chmod -R 777 /opt/cp2k \
        && ln -s /opt/cp2k/exe/local_hip/ /opt/cp2k/bin \
        && mkdir /tmp/benchmarks 

COPY /scripts /scripts

RUN chmod -R 777 /scripts

# Adding environment variable for Running as ROOT
ENV PATH=$PATH:/opt/cp2k/bin:/scripts \
    OMPI_MCA_pml=ucx \
    OMPI_MCA_pml_ucx_tls=any \
    OMPI_MCA_osc=ucx \
    OMPI_MCA_btl=^vader,tcp,uct \
    OMPI_MCA_pml_ucx_devices=any \
    UCX_TLS=self,sm,tcp,rocm

WORKDIR /opt/cp2k/benchmarks

CMD ["/bin/bash"]

