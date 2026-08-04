ARG IMAGE="rocm/dev-ubuntu-24.04:7.2-complete"

FROM ${IMAGE}

# ---------------------------------------------------------------------------
# Spack-based CP2K build. Unlike the previous recipe, this image does NOT
# build UCX, UCC, or OpenMPI by hand. Spack builds them itself, along with
# a fresh GCC toolchain, the full scientific stack, and CP2K. The Dockerfile
# is intentionally a thin layer over shared/cp2k_build.sh so the build
# recipe is identical for baremetal and container builds.
# ---------------------------------------------------------------------------

ARG GPU_ARCH=gfx950
ARG CPU_ARCH=zen5
ARG ROCM_VERSION=7.2.0
ARG ROCM_PATH=/opt/rocm-${ROCM_VERSION}
ARG GCC_VERSION=14.3.0
ARG SPACK_BRANCH=v1.1.1
ARG SPACK_PACKAGES_TAG=v2026.03.0
ARG BUILD_JOBS=32

ENV DEBIAN_FRONTEND=noninteractive

# System packages required to bootstrap Spack and build the GCC/MPI/CP2K
# stack from source. ROCm itself is provided by the base image.
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bzip2 \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        file \
        flex \
        gfortran \
        git \
        gnupg \
        gzip \
        libelf-dev \
        libnuma-dev \
        libstdc++-12-dev \
        libtool \
        libxml2-dev \
        m4 \
        make \
        nano \
        numactl \
        patch \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        ssh \
        tar \
        unzip \
        vim \
        wget \
        xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV ROCM_PATH=${ROCM_PATH} \
    PATH=${ROCM_PATH}/bin:/opt/cp2k/bin:${PATH} \
    LD_LIBRARY_PATH=${ROCM_PATH}/lib:${ROCM_PATH}/lib64:${LD_LIBRARY_PATH:-}

# Drop the shared build recipe into the image and run it. BUILD_ROOT lives
# under /opt so the resulting Spack tree is self-contained and easy to find.
WORKDIR /opt/cp2k-build
COPY shared /opt/cp2k-build/shared

RUN BUILD_ROOT=/opt/cp2k-build \
    SPACK_BRANCH=${SPACK_BRANCH} \
    SPACK_PACKAGES_TAG=${SPACK_PACKAGES_TAG} \
    GCC_VERSION=${GCC_VERSION} \
    CPU_ARCH=${CPU_ARCH} \
    GPU_ARCH=${GPU_ARCH} \
    ROCM_VERSION=${ROCM_VERSION} \
    ROCM_PATH=${ROCM_PATH} \
    BUILD_JOBS=${BUILD_JOBS} \
    /opt/cp2k-build/shared/cp2k_build.sh \
    && ln -sfn /opt/cp2k-build/cp2k /opt/cp2k

# Runtime defaults that match the run scripts.
ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_pml=ucx \
    OMPI_MCA_osc=ucx \
    OMPI_MCA_coll_ucc_enable=1 \
    OMPI_MCA_coll_ucc_priority=100 \
    UCX_TLS=self,sm,rocm_copy,rocm_ipc,ud_x \
    UCX_HANDLE_ERRORS=bt \
    UCX_MAX_RNDV_RAILS=1 \
    HSA_ENABLE_SDMA=0 \
    HSA_ENABLE_IPC_MODE_LEGACY=1 \
    HIP_MEM_POOL_SUPPORT=1
# Note: DBCSR_USE_ACC_G2G is not set image-wide. Per-benchmark launchers
# (e.g. scripts/run_dft_nrep2.sh) set it explicitly when needed.

CMD ["/bin/bash"]
