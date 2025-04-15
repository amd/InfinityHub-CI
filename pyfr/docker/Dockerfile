ARG IMAGE="rocm_gpu:6.4"

FROM ${IMAGE}

ARG PYFR_BRANCH="v1.15.0"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libmetis-dev \
        xz-utils \
        python3-h5py-mpi \
        python3-numpy \
        python3-mpi4py \
    && apt-get clean

WORKDIR /tmp

RUN git clone -b ${PYFR_BRANCH} https://github.com/PyFR/PyFR.git \
    && ls -lsa \
    && cd PyFR \
    && python3 setup.py install \    
    && git clone https://github.com/PyFR/PyFR-Test-Cases.git /examples/PyFR-Test-Cases 

COPY examples /examples

RUN chmod -R 777 /examples

WORKDIR /examples
CMD ["/bin/bash"]

