ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG ROCHPCG_BRANCH="develop"

WORKDIR /opt
# Installing rocHPCG
RUN git clone -b ${ROCHPCG_BRANCH} https://github.com/ROCmSoftwarePlatform/rocHPCG.git \
  && cd rocHPCG \
  && chmod a+x install.sh \
  && ./install.sh \
      --with-mpi=/opt/openmpi  \
      --with-rocm=/opt/rocm \
      --gpu-aware-mpi=ON \
      --reference \
  && rm -f /opt/rocm/bin/hpcg \
  && ln -s /opt/rocHPCG/build/release/bin/rochpcg /opt/rocm/bin/hpcg

CMD ["/bin/bash"]

