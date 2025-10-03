ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}
RUN mkdir /data
COPY data /data
RUN chmod -R g+w,o+w /data

ARG QMCPACK_BRANCH="develop"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libopenblas-dev libfftw3-dev libxml2-dev libboost-dev libhdf5-dev rocm-openmp openmp-extras-dev openmp-extras-runtime 

ENV PATH=/opt/qmcpack/bin:$PATH \
    LD_LIBRARY_PATH=$ROCM_PATH/lib/llvm/lib:$LD_LIBRARY_PATH \
    QMCPACK_MACHINE='qmcpack-container' \
    HSA_XNACK=1 \
    OMP_NUM_THREADS=4 \
    AMDDeviceLibs_DIR=$ROCM_PATH/lib/cmake \
    PYTHONPATH=/tmp/qmcpack/nexus/lib:$PYTHONPATH

WORKDIR /tmp

RUN git clone https://github.com/QMCPACK/qmcpack.git -b ${QMCPACK_BRANCH} && \
    mkdir /benchmark && \
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
     cmake \
        -D CMAKE_INSTALL_PREFIX=/opt/qmcpack/ \
        -D ROCM_PATH=/opt/rocm \
        -D CMAKE_C_COMPILER=/opt/rocm/bin/amdclang \
        -D CMAKE_CXX_COMPILER=/opt/rocm/bin/amdclang++ \
        -D QMC_MPI=OFF \
        -D QMC_GPU="openmp;hip" \
        -D QMC_GPU_ARCHS=${AMDGPU_TARGETS} \
        -D QMC_OFFLOAD_MEM_ASSOCIATED=ON \
        -D QMC_COMPLEX=OFF \
        -D QMC_MIXED_PRECISION=ON \
        -D QMC_DATA=/benchmark/qmc-data \
        .. && \
    make -j && \
    make install && \
    chmod -R 777 /opt/qmcpack && \
    rm -rf /tmp

WORKDIR /data

RUN tar -xf coral_doe_fom.tar.gz -C /benchmark && \
    rm coral_doe_fom.tar.gz && \ 
    cd /benchmark/coral_doe_fom && \
    ln -s /benchmark/qmc-data/NiO/NiO-fcc-supertwist111-supershift000-S64.h5 . && \
    chmod -R g+w,o+w /benchmark

WORKDIR /benchmark


CMD ["/bin/bash"]

