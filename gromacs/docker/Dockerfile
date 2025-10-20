ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG GROMACS_BRANCH="4947-hip-feature-enablement"
ARG MPI_ENABLED="off"

# Installing Gromacs - HIP
RUN git clone -b ${GROMACS_BRANCH} https://gitlab.com/gromacs/gromacs.git \
  && cd gromacs \
  && mkdir build  \
  && cd build   \
  && cmake -DCMAKE_BUILD_TYPE=Release \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_CXX_COMPILER=g++ \
        -DGMX_MPI=${MPI_ENABLED} \
        -DGMX_HIP_TARGET_ARCH=${AMDGPU_TARGETS} \
        -DGMX_GPU=HIP \
        -DREGRESSIONTEST_DOWNLOAD=OFF \
      .. \
  && make -j $(nproc) \
  && make install \
  && rm -rf /tmp/*

COPY benchmark /benchmarks
RUN chmod -R g+w,o+w /benchmarks

ENV ROC_ACTIVE_WAIT_TIMEOUT=0 \
    AMD_DIRECT_DISPATCH=1 \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/gromacs/lib/ \
    PATH=/benchmarks/:/usr/local/gromacs/bin:$PATH

# GPL -- need to include link to source code
RUN echo "echo GROMACS - HIP  source code located at https://gitlab.com/gromacs/gromacs.git " >> /etc/profile.d/gromacs.sh

CMD ["/bin/bash"]

