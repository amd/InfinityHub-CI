ARG IMAGE="rocm_gpu:6.0"

FROM ${IMAGE}
RUN mkdir /data
COPY data /data
RUN chmod -R g+w,o+w /data

ARG QMCPACK_BRANCH="develop"
ARG HDF5_BRANCH="hdf5-1_14_1"

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

ENV PATH=/opt/qmcpack/bin:$PATH:$HDF5_HOME/bin:$PATH \
    LD_LIBRARY_PATH=$HDF5_HOME/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$HDF5_HOME/lib:$LIBRARY_PATH \
    C_INCLUDE_PATH=$HDF5_HOME/include:$C_INCLUDE_PATH \
    CPLUS_INCLUDE_PATH=$HDF5_HOME/include:$CPLUS_INCLUDE_PATH \    
    PKG_CONFIG_PATH=$HDF5_HOME/lib/pkgconfig:$PKG_CONFIG_PATH \
    QMCPACK_MACHINE='qmcpack-container' \
    HSA_XNACK=1 \
    OMPX_APU_MAPS=1 \
    OMP_NUM_THREADS=4 \
    AMDDeviceLibs_DIR=$ROCM_PATH/lib/cmake \
    PYTHONPATH=/tmp/qmcpack/nexus/lib:$PYTHONPATH

RUN apt-get update && \
    apt-get install -y libopenblas-dev libfftw3-dev libxml2-dev libboost-dev

WORKDIR /tmp

RUN git clone https://github.com/QMCPACK/qmcpack.git -b ${QMCPACK_BRANCH} && \
    mkdir /benchmark && \
    chmod -R g+w,o+w /benchmark && \ 
    cd /benchmark && \
    mkdir qmc-data && \
    cd qmc-data/ && \
    mkdir NiO && \
    cd NiO/ && \
    curl -L -O -J https://anl.box.com/shared/static/uduxhujxkm1st8pau9muin255cxr2blb.h5 && \ 
    curl -L -O -J https://anl.box.com/shared/static/g5ceycyjhb2b6segk7ibxup2hxnd77ih.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/47sjyru249ct438j450o7nos6siuaft2.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/3sgw5wsfkbptptxyuu8r4iww9om0grwk.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/f2qftlejohkv48alidi5chwjspy1fk15.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/hiysnip3o8e3sp15e3e931ca4js3zsnw.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/tjdc8o3yt69crl8xqx7lbmqts03itfve.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/7jzdg0yp2njanz5roz5j40lcqc4poxqj.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/yneul9l7rq2ad35vkt4mgmr2ijxt5vb6.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/a0j8gjrfvco0mnko00wq5ujt5oidlg0y.h5 && \
    curl -L -O -J https://anl.box.com/shared/static/373klkrpmc362aevkt7gb0s8rg1hs9ps.h5 && \
    cd /tmp/qmcpack/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/qmcpack/ -DBUILD_UNIT_TESTS=OFF -DCMAKE_VERBOSE_MAKEFILE=ON -DROCM_PATH=$ROCM_PATH   -DCMAKE_C_COMPILER=`which mpicc`  -DCMAKE_CXX_COMPILER=`which mpicxx`  -DQMC_MPI=ON -DOFFLOAD_TARGET=amdgcn-amd-amdhsa  -DOFFLOAD_ARCH=gfx90a,gfx942:xnack+  -DENABLE_CUDA=ON  -DQMC_CUDA2HIP=ON  -DCMAKE_HIP_ARCHITECTURES=gfx90a,gfx942:xnack+  -D QMC_COMPLEX=OFF  -D QMC_MIXED_PRECISION=ON  -D QMC_DATA=/benchmark/qmc-data  .. && \
    make -j && \
    make install && \
    chmod -R 777 /opt/qmcpack && \
    rm -rf /tmp 
    
    

WORKDIR /data

RUN tar -xf coral_doe_fom.tar.gz -C /benchmark && \
    rm coral_doe_fom.tar.gz && \ 
    cd /benchmark/coral_doe_fom && \
    ln -s /benchmark/qmc-data/NiO/NiO-fcc-supertwist111-supershift000-S64.h5 .

WORKDIR /benchmark


CMD ["/bin/bash"]

