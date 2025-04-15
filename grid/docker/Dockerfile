ARG IMAGE="rocm_gpu:6.3"

FROM ${IMAGE}

ARG GRID_BRANCH="develop"

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libmpfr-dev \
    libssl-dev \
    zlib1g-dev \
  && apt-get clean


WORKDIR /tmp
#Build app
ENV GRID_PATH=/opt/grid

RUN git clone -b ${GRID_BRANCH} https://github.com/paboyle/Grid.git \
   && cd Grid \
   && ./bootstrap.sh \
   && mkdir build \
   && cd build \
   && ../configure \
        --prefix=$GRID_PATH \
        --enable-unified=no \
        --enable-accelerator=hip \
        --enable-accelerator-aware-mpi=yes \
        --enable-setdevice \
        --enable-alloc-cache \
        --enable-shm=nvlink \
        --enable-comms=mpi3-auto \
        --enable-simd=GPU \
        --enable-gen-simd-width=64 \
        --disable-fermion-reps \
        CXX=hipcc \
        MPICXX=mpicxx \
        CPPFLAGS="-I${ROCM_PATH}/include -I${ROCM_PATH}/include/roctracer -std=c++17 --offload-arch=$AMDGPU_TARGETS" \
        LDFLAGS="-L${ROCM_PATH}/lib -lhipblas -L${ROCM_PATH}/lib/roctracer -lroctracer64 -lroctx64 -std=c++17" \
   && make -j 8 \
   && make install \
   && cd /tmp \
   && rm -rf Grid

COPY ./benchmark $GRID_PATH/benchmark/.
RUN chmod a+rx  $GRID_PATH/benchmark/*.sh \
      && ln -s $GRID_PATH/benchmark/ /benchmark

WORKDIR /benchmark

ENV PATH=$GRID_PATH/bin:$PATH

CMD ["/bin/bash"]
