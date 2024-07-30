ARG IMAGE="rocm_gpu:5.7.3"

FROM ${IMAGE}
ARG OPENFOAM_VERSION="v2406"
ARG SCOTCH_VER="v7.0.4"
ARG PETSC_VER="main"
ARG USE_HYPRE=TRUE

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bison libfl-dev libfftw3-dev libopenblas-dev libboost-all-dev libmpfr-dev libelf1  libomp-dev libgmp-dev

## OpenFOAM creates environment conflicts with OpenMPI Libraries and Headers, removing them from ENV. 
ENV LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib \
        LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64 \
        C_INCLUDE_PATH=$ROCM_PATH/include:$ROCM_PATH/include/hipsparse \
        CPLUS_INCLUDE_PATH=$ROCM_PATH/include:$ROCM_PATH/include/hipsparse

WORKDIR /tmp
# Install Scotch, PETSc, then OpenFOAM
ENV OPENFOAM_DIR=/home/OpenFOAM/OpenFOAM-${OPENFOAM_VERSION} \
    THIRDPARTY_DIR=/home/OpenFOAM/ThirdParty-${OPENFOAM_VERSION} \
    WM_NCOMPPROCS=8

SHELL ["/bin/bash", "-c"]

WORKDIR /home/OpenFOAM/

RUN git clone -b OpenFOAM-${OPENFOAM_VERSION} https://develop.openfoam.com/Development/openfoam.git OpenFOAM-${OPENFOAM_VERSION}
RUN git clone -b ${OPENFOAM_VERSION} https://develop.openfoam.com/Development/ThirdParty-common.git ThirdParty-${OPENFOAM_VERSION}

COPY scripts/makePETSC.hip /home/OpenFOAM/ThirdParty-${OPENFOAM_VERSION}/makePETSC.hip
RUN chmod 777 /home/OpenFOAM/ThirdParty-${OPENFOAM_VERSION}/makePETSC.hip


RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && cd ThirdParty-${OPENFOAM_VERSION} \
    && git clone -b ${SCOTCH_VER} https://gitlab.inria.fr/scotch/scotch.git scotch_${SCOTCH_VER} \
    && sed -i -e "s|.*SCOTCH_VERSION=scotch_.*|SCOTCH_VERSION=scotch_${SCOTCH_VER}|g" ${OPENFOAM_DIR}/etc/config.sh/scotch \
    && ./Allwmake -q

# PETSc 3.18.1 and 3.18.2 have issues with GAMG and CUPM interface, but fixes already included in `main`
RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && cd ThirdParty-${OPENFOAM_VERSION} \
    && git clone -b ${PETSC_VER} https://gitlab.com/petsc/petsc.git petsc-${PETSC_VER} \
    && sed -i -e "s|petsc_version=petsc-.*|petsc_version=petsc-${PETSC_VER}|g" ${OPENFOAM_DIR}/etc/config.sh/petsc \
    && if [[ "${USE_HYPRE}" == "TRUE" ]] ; then \
        ./makePETSC.hip; \
    else \
        ./makePETSC.hip -no-hypre; \
    fi

RUN source ${OPENFOAM_DIR}/etc/bashrc && env

RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && if $SHELL foamSystemCheck | grep -iq 'fail'; then \
        echo "foamSystemCheck failed" 1>&2 \
        && exit 1; \
    fi

RUN source ${OPENFOAM_DIR}/etc/bashrc && env

RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && echo ${WM_PROJECT_DIR} \
    && cd ${OPENFOAM_DIR} \
    && ./Allwmake -q -l

ENV PATH=${OPENFOAM_DIR}/bin:${OPENFOAM_DIR}/platforms/linux64GccDPInt32Opt/bin:$PATH \
    LD_LIBRARY_PATH=${OPENFOAM_DIR}/platforms/linux64GccDPInt32Opt/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=${OPENFOAM_DIR}/platforms/linux64GccDPInt32Opt/lib:$LIBRARY_PATH 


RUN source ${OPENFOAM_DIR}/etc/bashrc \
    && cd ${OPENFOAM_DIR} \
    && git submodule update --init ${OPENFOAM_DIR}/modules/external-solver \
    && cd ${OPENFOAM_DIR}/modules/external-solver \
    && ./Allwmake -j -q -l \
    && mkdir /openfoam/ \
    && cp -r $(dirname $(find /root/ -iname libpetscFoam.so)) /openfoam

ENV PATH=${THIRDPARTY_DIR}/petsc-${PETSC_VER}/DPInt32/bin:${THIRDPARTY_DIR}/scotch_${SCOTCH_VER}/bin:$PATH \
    LD_LIBRARY_PATH=${THIRDPARTY_DIR}/petsc-${PETSC_VER}/DPInt32/lib:/openfoam/lib/:$LD_LIBRARY_PATH \
    LIBRARY_PATH=${THIRDPARTY_DIR}/petsc-${PETSC_VER}/DPInt32/lib:/openfoam/lib/:$LIBRARY_PATH

COPY /scripts /benchmark

WORKDIR /benchmark

RUN chmod -R 777 /benchmark \
    && ./load_benchmark.sh --prefix /benchmark \
    && chmod -R 777 /benchmark

CMD ["/bin/bash"]

