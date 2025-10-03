ARG IMAGE="rocm_gpu:6.4"

FROM ${IMAGE}

ARG PELEC_BRANCH="development"

WORKDIR /opt/

ENV AMD_ARCH=$AMDGPU_TARGETS \
    HIP_PLATFORM=amd

RUN git clone -b ${PELEC_BRANCH} --recursive  https://github.com/AMReX-Combustion/pelec/ \
    && sed -i 's/defined(__HIP_PLATFORM_HCC__)/defined(__HIP_PLATFORM_HCC__) || defined(__HIP_PLATFORM_AMD__)/'  /opt/pelec/Submodules/PelePhysics/Submodules/sundials/include/sundials/sundials_hip_policies.hpp \
    && cd pelec/Exec/RegTests/PMF \
    && export MODELS="drm19 dodecane_lu" \
    && for model in $MODELS; do \
        echo $model \
        && make -j $(nproc) USE_HIP=TRUE USE_MPI=TRUE Chemistry_Model=$model TPLrealclean \
        && make -j $(nproc) USE_HIP=TRUE USE_MPI=TRUE Chemistry_Model=$model TPL \
        && make -j $(nproc) USE_HIP=TRUE USE_MPI=TRUE Chemistry_Model=$model realclean \
        && make -j $(nproc) USE_HIP=TRUE USE_MPI=TRUE Chemistry_Model=$model \
        && ls \
        && mv  PeleC3d.hip.MPI.HIP.ex  PeleC3d.hip.MPI.HIP.ex.$model; \
    done

COPY ./benchmarks/. /opt/pelec/Exec/RegTests/PMF/.

RUN chmod -R 777 /opt/pelec/Exec/RegTests/PMF

WORKDIR /opt/pelec/Exec/RegTests/PMF

CMD ["/bin/bash"]
