ARG IMAGE="rocm_gpu:6.2"

FROM ${IMAGE}

ARG GROMACS_BRANCH="develop_2023_amd_sprint_rocm6"
ARG MPI_ENABLED="off"

# Installing Gromnacs - HIP
RUN git clone -b ${GROMACS_BRANCH} https://github.com/ROCmSoftwarePlatform/Gromacs.git \
  && cd Gromacs \
  && mkdir build  \
  && cd build   \
  && cmake -DBUILD_SHARED_LIBS=off \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_FLAGS="-Ofast -ggdb " \
        -DCMAKE_CXX_FLAGS="-Ofast -ggdb " \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DGMX_BUILD_FOR_COVERAGE=off \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DGMX_MPI=${OMPI_ENABLED} \
        -DGMX_GPU=HIP \
        -DGMX_OPENMP=on \
        -DCMAKE_HIP_ARCHITECTURES="$GPU_TARGET" \
        -DGMX_SIMD=AVX2_256 \
        -DREGRESSIONTEST_DOWNLOAD=OFF \
        -DBUILD_TESTING=ON \
        -DGMXBUILD_UNITTESTS=ON \
        -DGMX_GPU_USE_VKFFT=on \
        -DHIP_HIPCC_FLAGS="-O3 -ggdb --offload-arch=$GPU_TARGET" \
        -DCMAKE_EXE_LINKER_FLAGS=" -fopenmp" \
      .. \
  && make -j $(nproc) \
  && make install \
  && rm -rf /tmp/*

COPY benchmark /benchmarks
RUN chmod -R g+w,o+w /benchmarks

ENV GMX_GPU_DD_COMMS=1 \
    GMX_GPU_PME_PP_COMMS=1 \
    GMX_FORCE_UPDATE_DEFAULT_GPU=1 \
    ROC_ACTIVE_WAIT_TIMEOUT=0 \
    AMD_DIRECT_DISPATCH=1 \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/gromacs/lib/ \
    PATH=/benchmarks/:/usr/local/gromacs/bin:$PATH

# GPL -- need to include link to source code
RUN echo "echo Gromacs - HIP  source code located at https://github.com/ROCmSoftwarePlatform/Gromacs.git " >> /etc/profile.d/gromacs.sh

CMD ["/bin/bash"]

