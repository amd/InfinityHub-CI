ARG IMAGE="rocm_gpu:6.1.1"

FROM ${IMAGE}

ARG RAJA_BRANCH="develop"
ARG RAJAPERF_BRANCH="develop"
ARG ENABLE_OPENMP=ON
ARG ENABLE_OMPI=ON
WORKDIR /opt

RUN git clone --recursive -b ${RAJA_BRANCH} https://github.com/LLNL/raja.git \
    && cd raja \
    && mkdir build \
    && cd build \
    && cmake .. \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/opt/raja \
        -D BUILD_SHARED_LIBS=OFF \
        -D CMAKE_HIP_ARCHITECTURES=${GPU_TARGET} \
        -D ROCM_ROOT_DIR=${ROCM_PATH} \
        -D HIP_ROOT_DIR=${ROCM_PATH}/hip \
        -D HIP_PATH=${ROCM_PATH}/llvm/bin \
        -D CMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/amdclang \
        -D CMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/amdclang++ \
        -D GPU_TARGETS=${GPU_TARGET} \
        -D AMDGPU_TARGETS=${GPU_TARGET} \
        -D CMAKE_CXX_FLAGS="-munsafe-fp-atomics" \
        -D BLT_CXX_STD=c++14 \
        -D ENABLE_MPI=${ENABLE_OMPI} \
        -D ENABLE_OPENMP=${ENABLE_OPENMP} \
        -D ENABLE_HIP=ON \
        -D ENABLE_CUDA=OFF \
        -D RAJA_COMPILER="RAJA_COMPILER_CLANG" \
        -D CMAKE_CXX_FLAGS_RELEASE="-O2" \
        -D RAJA_HIPCC_FLAGS="-fPIC -O2" \
    && make -j $(nproc) \
    && make install 

RUN git clone --recursive -b ${RAJAPERF_BRANCH} https://github.com/LLNL/rajaperf.git \
    && cd rajaperf \
    && mkdir build \
    && cd build \
    && cmake .. \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/opt/rajaperf \
        -D BUILD_SHARED_LIBS=OFF \
        -D CMAKE_HIP_ARCHITECTURES=${GPU_TARGET} \
        -D ROCM_ROOT_DIR=${ROCM_PATH} \
        -D HIP_ROOT_DIR=${ROCM_PATH}/hip \
        -D HIP_PATH=${ROCM_PATH}/llvm/bin \
        -D CMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/amdclang \
        -D CMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/amdclang++ \
        -D GPU_TARGETS=${GPU_TARGET} \
        -D AMDGPU_TARGETS=${GPU_TARGET} \
        -D CMAKE_CXX_FLAGS="-munsafe-fp-atomics" \
        -D BLT_CXX_STD=c++14 \
        -D ENABLE_MPI=${ENABLE_OMPI} \
        -D ENABLE_OPENMP=${ENABLE_OPENMP} \
        -D ENABLE_OPENMP=ON \
        -D ENABLE_CUDA=OFF \
        -D RAJA_COMPILER="RAJA_COMPILER_CLANG" \
        -D CMAKE_CXX_FLAGS_RELEASE="-O2" \
        -D RAJA_HIPCC_FLAGS="-fPIC -O2" \
    && make -j $(nproc) \
    && make install

ENV PATH=$PATH:/opt/rajaperf/bin

CMD ["/bin/bash"]
