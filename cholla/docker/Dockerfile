ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG CHOLLA_BRANCH="v3.0.0"
ARG HDF5_BRANCH="hdf5_1.14.4.3"

ENV HDF5_HOME=/opt/hdf5

WORKDIR /tmp

#Installing HDF5 download here: https://www.hdfgroup.org/downloads/hdf5/source-code/
RUN cd /tmp \
    && git clone --recursive https://github.com/HDFGroup/hdf5.git -b ${HDF5_BRANCH} \
    && cd hdf5 \
    && CC=mpicc \
        ./configure --prefix=$HDF5_HOME --enable-parallel \
    && make -j 16 \
    && make install \
    && cd /tmp \
    && rm -rf hdf5


ENV PATH=$HDF5_HOME/bin:$PATH \
    LD_LIBRARY_PATH=$HDF5_HOME/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$HDF5_HOME/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$HDF5_HOME/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$HDF5_HOME/include:$CPLUS_INCLUDE_PATH \    
    PKG_CONFIG_PATH=$HDF5_HOME/lib/pkgconfig:$PKG_CONFIG_PATH \
    CHOLLA_MACHINE='cholla-container'

COPY ./make.host.cholla-container /tmp/.

WORKDIR /opt

RUN sed -i "s/AMDGPU_TARGETS/${AMDGPU_TARGETS}/" /tmp/make.host.cholla-container \
    && git clone --recursive https://github.com/cholla-hydro/cholla.git -b ${CHOLLA_BRANCH} \
    && cp /tmp/make.host.cholla-container /opt/cholla/builds \
    && cd cholla \
    && make \
    && mkdir /benchmark \
    && chmod -R 777 /benchmark 

WORKDIR /benchmark

ENV PATH=$PATH:/opt/cholla/bin

CMD ["/bin/bash"]

