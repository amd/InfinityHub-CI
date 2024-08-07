ARG IMAGE="rocm_gpu:6.2"

FROM ${IMAGE}

ARG PYFR_BRANCH="v1.15.0"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libmetis-dev \
        xz-utils \
    && apt-get clean

WORKDIR /tmp

RUN git clone -b ${PYFR_BRANCH} https://github.com/PyFR/PyFR.git \
    && cd PyFR \
    && pip install mpi4py numpy==1.26.4 \
    && python3 setup.py install \
    && git clone https://github.com/PyFR/PyFR-Test-Cases.git /examples/PyFR-Test-Cases 

COPY examples /examples

RUN chmod -R 777 /examples

WORKDIR /examples
CMD ["/bin/bash"]

