ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG JSON_FORTRAN_BRANCH="master"
ARG NEKO_BRANCH="v0.8.1"

# Update and Install basic Linux development tools
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libopenblas-dev \
  && apt-get clean

WORKDIR /tmp


RUN git clone -b ${JSON_FORTRAN_BRANCH} https://github.com/jacobwilliams/json-fortran.git \
    && cd json-fortran \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/json-fortran -DUSE_GNU_INSTALL_CONVENTION=ON -DCMAKE_Fortran_FLAGS="-fPIC" .. \
    && make install

ENV PKG_CONFIG_PATH=/opt/json-fortran/lib/pkgconfig:$PKG_CONFIG_PATH \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/json-fortran/lib

WORKDIR /opt

RUN git clone https://github.com/Nek5000/gslib.git \
    && cd gslib \
    && make

RUN git clone -b ${NEKO_BRANCH} https://github.com/ExtremeFLOW/neko \
    && cd neko \
    && ./regen.sh \
    && ./configure \
        HIP_HIPCC_FLAGS="-O3 -fPIE --offload-arch=${AMDGPU_TARGETS}" \
        HIPCC=${ROCM_PATH}/bin/hipcc \
        --prefix=/opt/neko \
        --with-hip=${ROCM_PATH} \
        --enable-device-mpi \
        --with-gslib=/opt/gslib/build/ \
    && make \
    && make install \
    && chmod -R 777 /opt/neko

WORKDIR /opt/neko/bench

ENV PATH=$PATH:/opt/neko/bin \
    PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/neko/lib/pkgconfig \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/neko/lib  

CMD ["/bin/bash"]
