ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG RAJA_BRANCH="develop"
ARG RAJAPERF_BRANCH="develop"
ARG ENABLE_OPENMP=ON
ARG ENABLE_OMPI=OFF
WORKDIR /opt

RUN DEBIAN_FRONTEND=noninteractive apt install -y ninja-build

RUN git clone --recursive -b ${RAJA_BRANCH} https://github.com/LLNL/raja.git \
    && cd raja \
    && mkdir build \
    && cd build \
    && cmake .. \
        -G Ninja \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/opt/raja \
        -D BUILD_SHARED_LIBS=ON \
        -D CMAKE_HIP_ARCHITECTURES=${AMDGPU_TARGETS} \
        -D ROCM_ROOT_DIR=${ROCM_PATH} \
        -D HIP_ROOT_DIR=${ROCM_PATH}/hip \
        -D HIP_PATH=${ROCM_PATH}/llvm/bin \
        -D CMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/amdclang \
        -D CMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/amdclang++ \
        -D AMDGPU_TARGETS=${AMDGPU_TARGETS} \
        -D AMDGPU_TARGETS=${AMDGPU_TARGETS} \
        -D CMAKE_CXX_FLAGS="-munsafe-fp-atomics" \
        -D CMAKE_CXX_STANDARD=17 \
        -D CMAKE_CXX_STANDARD_REQUIRED=ON \
        -D CMAKE_CXX_EXTENSIONS=OFF \
        -D CMAKE_HIP_STANDARD=17 \
        -D BLT_CXX_STD=c++17 \
        -D ENABLE_MPI=${ENABLE_OMPI} \
        -D ENABLE_OPENMP=${ENABLE_OPENMP} \
        -D ENABLE_HIP=ON \
        -D ENABLE_CUDA=OFF \
        -D RAJA_COMPILER="RAJA_COMPILER_CLANG" \
        -D CMAKE_CXX_FLAGS_RELEASE="-O2" \
        -D RAJA_HIPCC_FLAGS="-fPIC -O2" \
        -D RAJA_HOST_CONFIG_LOADED=ON \
    && ninja -j $(nproc) \
    && ninja install 

RUN git clone --recursive -b ${RAJAPERF_BRANCH} https://github.com/LLNL/rajaperf.git \
    && cd rajaperf \
    && mkdir build \
    && cd build \
    && cmake .. \
        -G Ninja \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/opt/rajaperf \
        -D ENABLE_HIP=ON \
        -D BUILD_SHARED_LIBS=ON \
        -D CMAKE_HIP_ARCHITECTURES=${AMDGPU_TARGETS} \
        -D ROCM_ROOT_DIR=${ROCM_PATH} \
        -D HIP_ROOT_DIR=${ROCM_PATH}/hip \
        -D HIP_PATH=${ROCM_PATH}/llvm/bin \
        -D CMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/amdclang \
        -D CMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/amdclang++ \
        -D AMDGPU_TARGETS=${AMDGPU_TARGETS} \
        -D AMDGPU_TARGETS=${AMDGPU_TARGETS} \
        -D CMAKE_CXX_FLAGS="-munsafe-fp-atomics" \
        -D CMAKE_CXX_STANDARD=17 \
        -D CMAKE_CXX_STANDARD_REQUIRED=ON \
        -D CMAKE_CXX_EXTENSIONS=OFF \
        -D CMAKE_HIP_STANDARD=17 \
        -D BLT_CXX_STD=c++17 \
        -D ENABLE_MPI=${ENABLE_OMPI} \
        -D ENABLE_OPENMP=${ENABLE_OPENMP} \
        -D ENABLE_CUDA=OFF \
        -D RAJA_COMPILER="RAJA_COMPILER_CLANG" \
        -D CMAKE_CXX_FLAGS_RELEASE="-O2" \
        -D RAJA_HIPCC_FLAGS="-fPIC -O2" \
        -D RAJA_HOST_CONFIG_LOADED=ON \
        -D CMAKE_PREFIX_PATH="$ROCM_PATH" \
    && ninja -j $(nproc) \
    && ninja install

ENV PATH=$PATH:/opt/rajaperf/bin \
    LD_LIBRARY_PATH=/opt/rajaperf/build/lib:$LD_LIBRARY_PATH

CMD ["/bin/bash"]
