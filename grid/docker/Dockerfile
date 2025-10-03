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
ENV GRID_PATH=/opt/grid \
    OMPI_CC=amdclang \
    OMPI_CXX=amdclang++

RUN git clone -b ${GRID_BRANCH} https://github.com/paboyle/Grid.git \
   && cd Grid \
   && sed -i 's/hipblasDoubleComplex/hipDoubleComplex/g' Grid/algorithms/blas/BatchedBlas.h \
   && sed -i 's/hipblasDoubleComplex/hipDoubleComplex/g' Grid/algorithms/blas/BatchedBlas.cc \
   && sed -i 's/hipblasComplex/hipComplex/g' Grid/algorithms/blas/BatchedBlas.h \
   && sed -i 's/hipblasComplex/hipComplex/g' Grid/algorithms/blas/BatchedBlas.cc \
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
   && make -j $(nproc) \
   && make install \
   && cd /tmp \
   && rm -rf Grid

COPY ./benchmark $GRID_PATH/benchmark/.
RUN chmod a+rx  $GRID_PATH/benchmark/*.sh \
      && ln -s $GRID_PATH/benchmark/ /benchmark

WORKDIR /benchmark

ENV PATH=$GRID_PATH/bin:$PATH

CMD ["/bin/bash"]
