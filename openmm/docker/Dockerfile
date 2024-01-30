ARG IMAGE="rocm_gpu:5.7"

FROM ${IMAGE}

ARG OPENMM_BRANCH="8.1.0"
ARG OPENMMHIP_BRANCH="master"

# Update and Install basic Linux development tools
RUN rm /etc/apt/sources.list.d/* \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    doxygen \
    swig \
    cython3 \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
  && pip3 install numpy scipy \
  && apt-get clean

ENV OPENMM_DIR=/opt/openmm \
    OPENMM_FFT_BACKEND=1

WORKDIR /tmp

ENV OPENMM_DIR=/opt/openmm \
    OPENMM_FFT_BACKEND=1

# Installing OpenMM
RUN git clone -b ${OPENMM_BRANCH} https://github.com/openmm/openmm.git \
  && cd openmm \
  && mkdir build install \
  && cd build \
  && cmake .. \
    -D CMAKE_INSTALL_PREFIX=$OPENMM_DIR \
    -D OPENMM_BUILD_OPENCL_LIB=off \
    -D OPENMM_BUILD_COMMON=ON \
  && make -j 8 \
  && make install \
  && make PythonInstall \
  && chmod -R 777 ../build

ENV PATH=$OPENMM_DIR/bin:$PATH \
    LD_LIBRARY_PATH=$OPENMM_DIR/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$OPENMM_DIR/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$OPENMM_DIR/include:$OPENMM_DIR/platforms/common/include/:$OPENMM_DIR/openmmapi/include/:$OPENMM_DIR/libraries/lepton/include/:$OPENMM_DIR/include/openmm/reference/:$OPENMM_DIR/:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$OPENMM_DIR/include:$OPENMM_DIR/platforms/common/include/:$OPENMM_DIR/openmmapi/include/:$OPENMM_DIR/libraries/lepton/include/:$OPENMM_DIR/include/openmm/reference/:$OPENMM_DIR/:$CPLUS_INCLUDE_PATH \
    PKG_CONFIG_PATH=$OPENMM_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

RUN git clone -b ${OPENMMHIP_BRANCH} https://github.com/amd/openmm-hip.git \
    && cd openmm-hip \
    && mkdir build \
    && cd build \
    && cmake .. \
      -D OPENMM_DIR=$OPENMM_DIR\
      -D CMAKE_INSTALL_PREFIX=$OPENMM_DIR\
      -D OPENMM_SOURCE_DIR=/tmp/openmm \
    && make -j 8 \
    && make install \
    && chmod -R 777 $OPENMM_DIR

WORKDIR /opt/openmm/examples/

# Adding environment variable for Running as ROOT and set MCA pml to UCX
ENV OMPI_MCA_pml=ucx \
    OMPI_MCA_osc=ucx \
    OMPI_MCA_pml_ucx_tls=any \
    OMPI_MCA_pml_ucx_devices=any \
    OMPI_MCA_pml_ucx_verbose=100

CMD ["/bin/bash"]
