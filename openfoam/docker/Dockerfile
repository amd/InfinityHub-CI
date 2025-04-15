ARG IMAGE="rocm_gpu:6.4"

FROM ${IMAGE}
ARG OPENFOAM_VERSION="v2406"
ARG SCOTCH_VER="v7.0.6"
ARG PETSC_VER="main"
ARG USE_HYPRE=FALSE

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
ENV WM_PROJECT_DIR=/home/OpenFOAM/OpenFOAM-${OPENFOAM_VERSION} \
    WM_THIRD_PARTY_DIR=/home/OpenFOAM/ThirdParty-${OPENFOAM_VERSION} \
    WM_PROJECT_VERSION=${OPENFOAM_VERSION} \
    WM_NCOMPPROCS=8

SHELL ["/bin/bash", "-c"]

WORKDIR /home/OpenFOAM/

RUN git clone -b OpenFOAM-${OPENFOAM_VERSION} https://develop.openfoam.com/Development/openfoam.git ${WM_PROJECT_DIR}
RUN git clone -b ${OPENFOAM_VERSION} https://develop.openfoam.com/Development/ThirdParty-common.git ${WM_THIRD_PARTY_DIR}

COPY scripts/makePETSC.hip ${WM_THIRD_PARTY_DIR}/makePETSC.hip
RUN chmod 777 ${WM_THIRD_PARTY_DIR}/makePETSC.hip


RUN source ${WM_PROJECT_DIR}/etc/bashrc \
    && cd ${WM_THIRD_PARTY_DIR} \
    && git clone -b ${SCOTCH_VER} https://gitlab.inria.fr/scotch/scotch.git scotch_${SCOTCH_VER} \
    && sed -i -e "s|.*SCOTCH_VERSION=scotch_.*|SCOTCH_VERSION=scotch_${SCOTCH_VER}|g" ${WM_PROJECT_DIR}/etc/config.sh/scotch \
    && ./Allwmake -q

# PETSc 3.18.1 and 3.18.2 have issues with GAMG and CUPM interface, but fixes already included in `main`
RUN source ${WM_PROJECT_DIR}/etc/bashrc \
    && cd ${WM_THIRD_PARTY_DIR} \
    && git clone -b ${PETSC_VER} https://gitlab.com/petsc/petsc.git petsc-${PETSC_VER} \
    && sed -i -e "s|petsc_version=petsc-.*|petsc_version=petsc-${PETSC_VER}|g" ${WM_PROJECT_DIR}/etc/config.sh/petsc \
    && if [[ "${USE_HYPRE}" == "TRUE" ]] ; then \
        ./makePETSC.hip; \
    else \
        ./makePETSC.hip -no-hypre; \
    fi

RUN source ${WM_PROJECT_DIR}/etc/bashrc && env

RUN source ${WM_PROJECT_DIR}/etc/bashrc \
    && if $SHELL foamSystemCheck | grep -iq 'fail'; then \
        echo "foamSystemCheck failed" 1>&2 \
        && exit 1; \
    fi

RUN source ${WM_PROJECT_DIR}/etc/bashrc && env

RUN source ${WM_PROJECT_DIR}/etc/bashrc \
    && echo ${WM_PROJECT_DIR} \
    && cd ${WM_PROJECT_DIR} \
    && ./Allwmake -q -l

ENV PATH=${WM_PROJECT_DIR}/bin:${WM_PROJECT_DIR}/platforms/linux64GccDPInt32Opt/bin:$PATH \
    LD_LIBRARY_PATH=${WM_PROJECT_DIR}/platforms/linux64GccDPInt32Opt/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=${WM_PROJECT_DIR}/platforms/linux64GccDPInt32Opt/lib:$LIBRARY_PATH 


RUN source ${WM_PROJECT_DIR}/etc/bashrc \
    && cd ${WM_PROJECT_DIR} \
    && git submodule update --init ${WM_PROJECT_DIR}/modules/external-solver \
    && cd ${WM_PROJECT_DIR}/modules/external-solver \
    && ./Allwmake -j -q -l \
    && mkdir /openfoam/ \
    && cp -r $(dirname $(find /root/ -iname libpetscFoam.so)) /openfoam

ENV PATH=${WM_THIRD_PARTY_DIR}/petsc-${PETSC_VER}/DPInt32/bin:${WM_THIRD_PARTY_DIR}/scotch_${SCOTCH_VER}/bin:$PATH \
    LD_LIBRARY_PATH=${WM_THIRD_PARTY_DIR}/petsc-${PETSC_VER}/DPInt32/lib:/openfoam/lib/:$LD_LIBRARY_PATH \
    LIBRARY_PATH=${WM_THIRD_PARTY_DIR}/petsc-${PETSC_VER}/DPInt32/lib:/openfoam/lib/:$LIBRARY_PATH

COPY /scripts /benchmark

WORKDIR /benchmark

RUN chmod -R 777 /benchmark \
    && ./load_benchmark.sh --prefix /benchmark \
    && chmod -R 777 /benchmark

CMD ["/bin/bash"]

