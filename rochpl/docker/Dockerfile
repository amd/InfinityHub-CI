ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG HPL_BRANCH="main"

WORKDIR /opt

# Installing rocHPL
RUN git clone -b ${HPL_BRANCH} https://github.com/ROCmSoftwarePlatform/rocHPL.git \
    && cd rocHPL \
    && ./install.sh \
        --prefix=/opt/rochpl \
        --with-rocm=/opt/rocm/ \
        --with-mpi=/opt/ompi \
    && rm -rf /tmp/rocHPL

ENV PATH=$PATH:/opt/rochpl:/opt/rochpl/bin

CMD ["/bin/bash"]