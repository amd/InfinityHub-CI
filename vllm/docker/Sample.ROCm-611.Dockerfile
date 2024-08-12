# default base image
ARG BASE_IMAGE="rocm/pytorch:rocm6.1.1_ubuntu20.04_py3.9_pytorch_staging"

ARG COMMON_WORKDIR=/app

# The following ARGs should be "0" or "1". If "1", the respective component will be built and installed on top of the base image
ARG BUILD_HIPBLASLT="1"
ARG BUILD_RCCL="1"
ARG BUILD_FA="1"
ARG BUILD_CUPY="0"
ARG BUILD_TRITON="1"
# This ARG should also be "0" or "1". If "1", the vLLM development directory is obtained via git clone.
# If "0", it is copied in from the local working directory.
ARG REMOTE_VLLM="0"

# -----------------------
# vLLM base image
FROM $BASE_IMAGE AS base
USER root

# Import BASE_IMAGE arg from pre-FROM
ARG BASE_IMAGE
ARG COMMON_WORKDIR
# Used as ARCHes for all components
ARG PYTORCH_ROCM_ARCH=gfx942
ENV PYTORCH_ROCM_ARCH="${PYTORCH_ROCM_ARCH}"
# dad add GPU_ARCHS for flash attention

# Install some basic utilities
RUN apt-get update && apt-get install python3 python3-pip -
RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev libfmt-dev libmsgpack-dev libsuitesparse-dev

ENV LLVM_SYMBOLIZER_PATH=/opt/rocm/llvm/bin/llvm-symbolizer
ENV PATH=$PATH:/opt/rocm/bin:/opt/conda/envs/py_3.9/lib/python3.9/site-packages/torch/bin:
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm/lib/:/opt/conda/envs/py_3.9/lib/python3.9/site-packages/torch/lib:
ENV CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/opt/conda/envs/py_3.9/lib/python3.9/site-packages/torch/include:/opt/conda/envs/py_3.9/lib/python3.9/site-packages/torch/include/torch/csrc/api/include/:/opt/rocm/include/:

WORKDIR ${COMMON_WORKDIR}

# -----------------------
# hipBLASLt build stages
FROM base AS build_hipblaslt
ARG HIPBLASLT_BRANCH="6f65c6e"
RUN git clone https://github.com/ROCm/hipBLASLt \
    && cd hipBLASLt \
    && git checkout ${HIPBLASLT_BRANCH} \
    && SCCACHE_IDLE_TIMEOUT=1800 ./install.sh --architecture ${PYTORCH_ROCM_ARCH} \
    && cd build/release \
    && make package
FROM scratch AS export_hipblaslt_1
ARG COMMON_WORKDIR
COPY --from=build_hipblaslt ${COMMON_WORKDIR}/hipBLASLt/build/release/*.deb /
FROM scratch AS export_hipblaslt_0
FROM export_hipblaslt_${BUILD_HIPBLASLT} AS export_hipblaslt

# -----------------------
# RCCL build stages
FROM base AS build_rccl
ARG RCCL_BRANCH="73221b4"
RUN git clone https://github.com/ROCm/rccl \
    && cd rccl \
    && git checkout ${RCCL_BRANCH} \
    && ./install.sh -p --amdgpu_targets ${PYTORCH_ROCM_ARCH}
FROM scratch AS export_rccl_1
ARG COMMON_WORKDIR
COPY --from=build_rccl ${COMMON_WORKDIR}/rccl/build/release/*.deb /
FROM scratch AS export_rccl_0
FROM export_rccl_${BUILD_RCCL} AS export_rccl

# -----------------------
# flash attn build stages
FROM base AS build_flash_attn
ARG FA_BRANCH="ae7928c"
ARG FA_REPO="https://github.com/ROCm/flash-attention.git"
RUN git clone ${FA_REPO} \
    && cd flash-attention \
    && git checkout ${FA_BRANCH} \
    && git submodule update --init \
    && GPU_ARCHS=gfx942  python3 setup.py bdist_wheel --dist-dir=dist
#    && GPU_ARCHS=${PYTORCH_ROCM_ARCH} python3 setup.py bdist_wheel --dist-dir=dist
FROM scratch AS export_flash_attn_1
ARG COMMON_WORKDIR
COPY --from=build_flash_attn ${COMMON_WORKDIR}/flash-attention/dist/*.whl /
FROM scratch AS export_flash_attn_0
FROM export_flash_attn_${BUILD_FA} AS export_flash_attn

# -----------------------
# CuPy build stages
FROM base AS build_cupy
ARG CUPY_BRANCH="hipgraph_enablement"
ENV PYTORCH_ROCM_ARCH=gfx942
RUN echo PYTORCH_ROCM_ARCH is "${PYTORCH_ROCM_ARCH}"
RUN git clone  https://github.com/ROCm/cupy.git \
    && cd cupy \
    && git checkout $CUPY_BRANCH \
    && git submodule update --init --recursive \
    && pip install mpi4py-mpich scipy==1.9.3 cython==0.29.* \
    && CC=$MPI_HOME/bin/mpicc python -m pip install mpi4py \
    && CUPY_INSTALL_USE_HIP=1 ROCM_HOME=/opt/rocm HCC_AMDGPU_TARGET=${PYTORCH_ROCM_ARCH} \
       python3 setup.py bdist_wheel --dist-dir=dist
FROM build_cupy AS export_cupy_1
ARG COMMON_WORKDIR
COPY --from=build_cupy ${COMMON_WORKDIR}/cupy/dist/*.whl /
FROM scratch AS export_cupy_0
FROM export_cupy_${BUILD_CUPY} AS export_cupy
#
## -----------------------
## Triton build stages
FROM base AS build_triton
ARG TRITON_BRANCH="main"
ARG TRITON_REPO="https://github.com/OpenAI/triton.git"
RUN git clone ${TRITON_REPO} \
    && cd triton \
    && git checkout ${TRITON_BRANCH} \
    && cd python \
    && python3 setup.py bdist_wheel --dist-dir=dist
FROM scratch AS export_triton_1
ARG COMMON_WORKDIR
COPY --from=build_triton ${COMMON_WORKDIR}/triton/python/dist/*.whl /
FROM scratch AS export_triton_0
FROM export_triton_${BUILD_TRITON} AS export_triton
#
# AMD-SMI build stages
FROM base AS build_amdsmi
RUN cd /opt/rocm/share/amd_smi \
    && pip wheel . --wheel-dir=dist
FROM scratch AS export_amdsmi
#RUN ls -lsa  /opt/rocm/share/amd_smi/dist/
#COPY --from=build_amdsmi /opt/rocm/share/amd_smi/dist/*.whl /
#
# -----------------------
# vLLM (and gradlib) fetch stages
FROM base AS fetch_vllm_0
ONBUILD COPY ./ vllm/
FROM base AS fetch_vllm_1
ARG VLLM_REPO="https://github.com/ROCm/vllm.git"
ARG VLLM_BRANCH="main"
ONBUILD RUN git clone ${VLLM_REPO} \
	    && cd vllm \
            && git checkout ${VLLM_BRANCH}
FROM fetch_vllm_${REMOTE_VLLM} AS fetch_vllm
#
# -----------------------
# vLLM (and gradlib) build stages
FROM fetch_vllm AS build_vllm
ARG COMMON_WORKDIR
# Install hipblaslt
RUN --mount=type=bind,from=export_hipblaslt,src=/,target=/install \
if ls /install/*.deb; then \
    apt-get purge -y hipblaslt \
    && dpkg -i /install/*.deb \
    && sed -i 's/, hipblaslt-dev \(.*\), hipcub-dev/, hipcub-dev/g' /var/lib/dpkg/status \
    && sed -i 's/, hipblaslt \(.*\), hipfft/, hipfft/g' /var/lib/dpkg/status; \
fi
# Build vLLM
RUN cd vllm \
    && python3 setup.py clean --all && python3 setup.py bdist_wheel --dist-dir=dist
# Build gradlib
RUN cd vllm/gradlib \
    && python3 setup.py clean --all && python3 setup.py bdist_wheel --dist-dir=dist
FROM scratch AS export_vllm
ARG COMMON_WORKDIR
COPY --from=build_vllm ${COMMON_WORKDIR}/vllm/dist/*.whl /
COPY --from=build_vllm ${COMMON_WORKDIR}/vllm/gradlib/dist/*.whl /
COPY --from=build_vllm ${COMMON_WORKDIR}/vllm/rocm_patch /rocm_patch
COPY --from=build_vllm ${COMMON_WORKDIR}/vllm/requirements*.txt /
COPY --from=build_vllm ${COMMON_WORKDIR}/vllm/benchmarks /benchmarks
#
# -----------------------
# Final vLLM image
FROM base AS final
ARG COMMON_WORKDIR
ARG BUILD_FA
#
RUN python3 -m pip install --upgrade pip && rm -rf /var/lib/apt/lists/*
# Error related to odd state for numpy 1.20.3 where there is no METADATA etc, but an extra LICENSES_bundled.txt.
# Manually remove it so that later steps of numpy upgrade can continue
RUN case "$(which python3)" in \
        *"/opt/conda/envs/py_3.9"*) \
            rm -rf /opt/conda/envs/py_3.9/lib/python3.9/site-packages/numpy-1.20.3.dist-info/;; \
        *) ;; esac

RUN --mount=type=bind,from=export_hipblaslt,src=/,target=/install \
    if ls /install/*.deb; then \
        apt-get purge -y hipblaslt \
        && dpkg -i /install/*.deb \
        && sed -i 's/, hipblaslt-dev \(.*\), hipcub-dev/, hipcub-dev/g' /var/lib/dpkg/status \
        && sed -i 's/, hipblaslt \(.*\), hipfft/, hipfft/g' /var/lib/dpkg/status; \
    fi

RUN --mount=type=bind,from=export_rccl,src=/,target=/install \
    if ls /install/*.deb; then \
        dpkg -i /install/*.deb \
        # RCCL needs to be installed twice
        && dpkg -i /install/*.deb \
        && sed -i 's/, rccl-dev \(.*\), rocalution/, rocalution/g' /var/lib/dpkg/status \
        && sed -i 's/, rccl \(.*\), rocalution/, rocalution/g' /var/lib/dpkg/status; \
    fi

RUN --mount=type=bind,from=export_flash_attn,src=/,target=/install \
    if ls /install/*.whl; then \
        pip install /install/*.whl; \
    fi

RUN --mount=type=bind,from=export_cupy,src=/,target=/install \
    if ls /install/*.whl; then \
        pip install /install/*.whl; \
    fi

RUN --mount=type=bind,from=export_triton,src=/,target=/install \
    if ls /install/*.whl; then \
        pip install /install/*.whl; \
    fi

#RUN --mount=type=bind,from=export_amdsmi,src=/,target=/install \
#    pip install /install/*.whl;

RUN python3 -m pip install --upgrade numba scipy huggingface-hub[cli]

# Install vLLM (and gradlib)
# Make sure punica kernels are built (for LoRA)
ENV VLLM_INSTALL_PUNICA_KERNELS=1
RUN --mount=type=bind,from=export_vllm,src=/,target=/install \
    cd /install \
    && pip install -U -r requirements-rocm.txt \
    && case "$(ls /opt | grep -Po 'rocm-[0-9]\.[0-9]')" in \
           *"rocm-6.0"*) \
               patch /opt/rocm/include/hip/amd_detail/amd_hip_bf16.h rocm_patch/rocm_bf16.patch;; \
           *"rocm-6.1"*) \
               cp rocm_patch/libamdhip64.so.6 /opt/rocm/lib/libamdhip64.so.6;; \
           *) ;; esac \
    && pip install *.whl

# Copy over the benchmark scripts as well
COPY --from=export_vllm /benchmarks ${COMMON_WORKDIR}/vllm/benchmarks

ENV RAY_EXPERIMENTAL_NOSET_ROCR_VISIBLE_DEVICES=1
ENV TOKENIZERS_PARALLELISM=false

# Performance environment variable.
ENV HIP_FORCE_DEV_KERNARG=1

CMD ["/bin/bash"]
