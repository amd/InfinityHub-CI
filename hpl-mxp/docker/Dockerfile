ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG HPLMXP_BRANCH="main"

WORKDIR /tmp/

RUN git clone -b ${HPLMXP_BRANCH} https://github.com/ROCm/rocHPL-MxP.git hpl_mxp \
    && cd hpl_mxp \
    && ./install.sh \
        --prefix=/opt/rochpl-mxp \
        --with-rocm=$ROCM_PATH \
        --with-mpi=$OPMI_PATH

ENV PATH=$PATH:/opt/rochpl-mxp:/opt/rochpl-mxp/bin

WORKDIR /tmp

CMD ["/bin/bash"]

