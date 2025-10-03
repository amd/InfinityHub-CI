ARG IMAGE=rocm_gpu:7.0

FROM ${IMAGE}

ARG KOKKOS_VERSION=4.2.01
ARG ENABLE_OPENMP=Off

# Adding rocm/cmake to the Environment 
ENV HSA_XNACK=1 

WORKDIR /tmp

RUN git clone https://github.com/google/benchmark.git \
    && cd benchmark \
    && mkdir build \
    && cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release -S . \
    && cmake --build . --config Release --target install

WORKDIR /

# Building and installing Kokkos
RUN git clone -b ${KOKKOS_VERSION} https://github.com/kokkos/kokkos.git \
        && cd kokkos \
        && mkdir build \
        && cd build \
        && if [ "$ENABLE_OPENMP" = "On" ]; then \
            cmake .. \
                -DCMAKE_BUILD_TYPE=Debug \
                -DCMAKE_CXX_COMPILER=amdclang++ \
                -DCMAKE_INSTALL_PREFIX=/opt/kokkos \
                -DKokkos_ENABLE_BENCHMARKS=On \
                -DKokkos_ENABLE_HIP=On \
                -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=On \
                -DKokkos_ENABLE_SERIAL=on \
                -DKokkos_ENABLE_TESTS=on \
                -DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=off \
                -DKokkos_ARCH_VEGA90A=On; \
                -DKokkos_ENABLE_OPENMP=${ENABLE_OPENMP} \
                -DKokkos_ENABLE_OPENMPTARGET=${ENABLE_OPENMP}; \
                -DCMAKE_CXX_FLAGS="--offload-arch=$AMDGPU_TARGETS" \
        else \
            cmake .. \
                -DCMAKE_BUILD_TYPE=Debug \
                -DCMAKE_CXX_COMPILER=hipcc \
                -DCMAKE_INSTALL_PREFIX=/opt/kokkos \
                -DKokkos_ENABLE_BENCHMARKS=On \
                -DKokkos_ENABLE_HIP=On \
                -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=On \
                -DKokkos_ENABLE_SERIAL=on \
                -DKokkos_ENABLE_TESTS=on \
                -DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=off \
                -DKokkos_ARCH_VEGA90A=On; \
                -DCMAKE_CXX_FLAGS="--offload-arch=$AMDGPU_TARGETS" \
        fi \
        && make -j $(nproc)\
        && make install \
        && chmod -R a+rwx /kokkos

#Adding Kokkos, libs, and headers to Environment
ENV PATH=$PATH:/opt/kokkos/bin \
    LD_LIBRARY_PATH=/opt/kokkos/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/opt/kokkos/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=/opt/kokkos/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=/opt/kokkos/include:$CPLUS_INCLUDE_PATH

RUN  git clone --recursive -b ${KOKKOS_VERSION} https://github.com/kokkos/kokkos-kernels.git kokkoskernels \
    && cd kokkoskernels \
    && mkdir build \
    && cd build \
    && if [ "$ENABLE_OPENMP" = "On" ]; then \
            export COMPILER=amdclang++; \
        else \
            export COMPILER=hipcc; \
        fi \
    && cmake .. \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_CXX_COMPILER=$COMPILER \
        -DCMAKE_INSTALL_PREFIX=/opt/kokkoskernels \
        -DCMAKE_PREFIX_PATH="/opt/kokkos;$ROCM_PATH" \
        -DKokkosKernels_ENABLE_TESTS=ON \
        -DKokkosKernels_ENABLE_EXAMPLES=ON \
        -DKokkosKernels_INST_ORDINAL_INT=ON \
        -DKokkosKernels_INST_ORDINAL_INT64_T=ON \
        -DKokkosKernels_INST_OFFSET_INT=ON \
        -DKokkosKernels_INST_FLOAT=ON \
        -DKokkosKernels_INST_COMPLEX_FLOAT=ON \
        -DKokkosKernels_INST_COMPLEX_DOUBLE=ON \
        -DKokkosKernels_ENABLE_TPL_ROCSPARSE=ON \
        -DKokkosKernels_ENABLE_TPL_ROCBLAS=ON \
        -DKokkosKernels_ENABLE_TPL_ROCSOLVER=ON \
        -DCMAKE_CXX_FLAGS="--offload-arch=$AMDGPU_TARGETS" \
    && make -j $(nproc)\
    && make install \
    && chmod -R a+rwx /kokkoskernels


WORKDIR /kokkos/build

#Adding Kokkos, libs, and headers to Environment
ENV LD_LIBRARY_PATH=/opt/kokkoskernels/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/opt/kokkoskernels/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=/opt/kokkoskernels/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=/opt/kokkoskernels/include:$CPLUS_INCLUDE_PATH

# Add any Build instructions that uses Kokkos Below. 


CMD [ "/bin/bash", "-c"]
