ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG SPECFEM3D_BRANCH="devel"

WORKDIR /opt

# Installing rocHPL
RUN git clone --recursive -b ${SPECFEM3D_BRANCH} https://github.com/SPECFEM/specfem3d.git \
    && cd specfem3d \
    && sed -i '/#include <sys\/resource.h>/a #include <string.h>' src/gpu/mesh_constants_gpu.h \
    && ./configure \
        --with-hip \
        --with-mpi \
        HIP_FLAGS="-fPIC -ftemplate-depth-2048 -fno-gpu-rdc -O2 -fdenormal-fp-math=ieee -fcuda-flush-denormals-to-zero -munsafe-fp-atomics --offload-arch=$AMDGPU_TARGETS" \
    && make all -j $(nproc)

COPY benchmarks /opt/specfem3d/benchmarks

RUN chmod -R 777 /opt/specfem3d/

ENV PATH=$PATH:/opt/specfem3d/bin:/opt/specfem3d/benchmarks

CMD ["/bin/bash"]
