ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG PICONGPU_BRANCH="dev"
ARG HDF5_BRANCH="hdf5-1_14_1"

# Update and Install basic Linux development tools
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        rsync \
        libpng-dev \
        libboost-program-options-dev \
        libboost-filesystem-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libboost-chrono-dev \
        libboost-atomic-dev \
        libboost-date-time-dev \
        libboost-math-dev \
        libboost-serialization-dev \
        libboost-fiber-dev \
        libboost-context-dev \
    && apt-get clean


WORKDIR /tmp

#pngwriter
RUN git clone https://github.com/pngwriter/pngwriter.git \
    && cd pngwriter \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/pngwriter .. \
    && make install

ENV LD_LIBRARY_PATH=/opt/pngwriter/lib \
    CMAKE_PREFIX_PATH=/opt/pngwriter:$CMAKE_PREFIX_PATH \
    HDF5_HOME=/opt/hdf5

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
    CPATH=$HDF5_HOME/include:$CPATH \
    INCLUDE=$HDF5_HOME/include:$INCLUDE \
    PKG_CONFIG_PATH=$HDF5_HOME/lib/pkgconfig:$PKG_CONFIG_PATH    

RUN git clone https://github.com/openPMD/openPMD-api.git openpmd \
    && cd openpmd \
    && mkdir build \
    && cd build \
    && cmake .. -DopenPMD_USE_MPI=ON -DHDF5_ENABLE_PARALLEL=ON -DCMAKE_INSTALL_PREFIX=/opt/openpmd-api \
    && make -j $(nproc) install 

ENV CMAKE_PREFIX_PATH=/opt/openpmd-api:$CMAKE_PREFIX_PATH \
        LD_LIBRARY_PATH=/opt/openpmd-api/lib:$LD_LIBRARY_PATH \
        PICSRC=/opt/picongpu

ENV PIC_EXAMPLES=$PICSRC/share/picongpu/examples \
        PATH=$PICSRC:$PICSRC/bin:$PICSRC/src/tools/bin:$PATH \
        PYTHONPATH=$PICSRC/lib/python:$PYTHONPATH \
        CXX=hipcc \
        OMPI_CXX=hipcc \
        OMPI_CC=hipcc
        
WORKDIR /opt

#Build Picongpu
RUN git clone -b ${PICONGPU_BRANCH} https://github.com/ComputationalRadiationPhysics/picongpu.git \
    && sed -i 's/template getAvailaibleSlotsDeviceFunction/template getAvailaibleSlotsDeviceFunction<AlpakaAcc>/g' ./picongpu/thirdParty/mallocMC/include/mallocMC/creationPolicies/Scatter.hpp \
    && mkdir -p /opt/picon-examples \
    && cd /opt/picon-examples \
    && pic-create $PICSRC/share/picongpu/tests/KHI_growthRate/ khi_fom \
    && cd khi_fom \
    && pic-build -f -b "hip:${AMDGPU_TARGETS}" \
    && chmod -R 777 /opt/picon-examples

ENV PATH=/opt/picon-examples/khi_fom/bin:$PATH

WORKDIR /opt/picon-examples

CMD ["/bin/bash"]

