ARG IMAGE="rocm_gpu:6.4"

FROM ${IMAGE}
ARG PETSC_BRANCH="main"

WORKDIR /tmp

# Installing PETSc
RUN git clone -b ${PETSC_BRANCH} https://github.com/petsc/petsc.git \
      && cd petsc \
      && ./configure \
            COPTFLAGS="-g -O3" \
            FOPTFLAGS="-g -O3" \
            CXXOPTFLAGS="-g -O3" \
            HIPOPTFLAGS="-g -ggdb -O3 -munsafe-fp-atomics -fPIC -w" \
            --prefix=/opt/petsc \
            --with-cuda=0 \
            --with-cc=mpicc \
            --with-cxx=mpicxx \
            --with-fc=mpif90 \
            --with-hip=1 \
            --with-hipc=hipcc \
            --with-hip-dir=${ROCM_PATH} \
            --with-hip-arch=${AMDGPU_TARGETS} \
            --with-precision=double \
            --with-clanguage=c \
            --download-fblaslapack \
            --download-hypre \
            --download-hypre-configure-arguments=--enable-unified-memory \
            --with-debugging=no \
      && make PETSC_DIR=/tmp/petsc PETSC_ARCH=arch-linux-c-opt all \
      && make PETSC_DIR=/tmp/petsc PETSC_ARCH=arch-linux-c-opt install \
      && make install \
      && rm -rf /tmp/*

COPY benchmark /opt/petsc
WORKDIR /opt/petsc
RUN chmod -R g+w,o+w /opt/petsc \
      && chmod a+rwx /opt/petsc/run-benchmark.sh \
      && ln -s /opt/petsc/share/petsc/examples/src src

# Adding environment variable for Running as ROOT and PETSc variables.
ENV PKG_CONFIG_PATH=/opt/petsc/lib/pkgconfig/ \
    PETSC_DIR=/opt/petsc \
    PETSC_ARCH=arch-linux-c-opt

CMD ["/bin/bash"]