ARG IMAGE=rocm_gpu:6.0

FROM ${IMAGE}

ARG KOKKOS_VERSION=4.2.00
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
                -DCMAKE_INSTALL_PREFIX=/opt/kokkos \
                -DKokkos_ENABLE_BENCHMARKS=On \
                -DKokkos_ENABLE_HIP=On \
                -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=On \
                -DKokkos_ENABLE_TESTS=On \
                -DKokkos_ARCH_VEGA90A=On; \
                -DKokkos_ENABLE_OPENMP=${ENABLE_OPENMP} \
                -DKokkos_ENABLE_OPENMPTARGET=${ENABLE_OPENMP}; \
        else \
            cmake .. \
                -DCMAKE_BUILD_TYPE=Debug \
                -DCMAKE_CXX_COMPILER=hipcc \
                -DCMAKE_INSTALL_PREFIX=/opt/kokkos \
                -DKokkos_ENABLE_BENCHMARKS=On \
                -DKokkos_ENABLE_HIP=On \
                -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=On \
                -DKokkos_ENABLE_TESTS=On \
                -DKokkos_ARCH_VEGA90A=On; \
        fi \
        && make -j $(nproc)\
        && make install \
        && chmod -R a+rwx /kokkos

WORKDIR /kokkos/build

#Adding Kokkos, libs, and headers to Environment
ENV PATH=$PATH:/opt/kokkos/bin \
    LD_LIBRARY_PATH=/opt/kokkos/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/opt/kokkos/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=/opt/kokkos/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=/opt/kokkos/include:$CPLUS_INCLUDE_PATH

# Add any Build instructions that uses Kokkos Below. 


CMD [ "/bin/bash", "-c"]
