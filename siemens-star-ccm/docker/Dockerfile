ARG UBUNTU_VERSION="jammy"

FROM ubuntu:${UBUNTU_VERSION}

ARG STAR_CCM_BINARY_ZIP="STAR-CCM+19.04.009_01_linux-x86_64-2.28_clang17.0"
ARG STAR_CCM_VERSION="19.04.009"
ARG CDLMD_LICENSE_FILE
ARG LM_PROJECT

#Siemens Licenses Details
ENV CDLMD_LICENSE_FILE=${CDLMD_LICENSE_FILE} \
    LM_PROJECT=${LM_PROJECT}

# Update and Install basic Linux development tools
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        ssh \
        vim \
        nano \
        curl \
        wget \
        unzip \
        libdrm-dev \
        libxtst6 \
        libelf-dev \
    && apt-get clean

# Adding OpenMPI Environment Variables to reduce errors
ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    UCX_WARN_UNUSED_ENV_VARS=n

WORKDIR /opt/

COPY sources/${STAR_CCM_BINARY_ZIP}.zip ${STAR_CCM_BINARY_ZIP}.zip

RUN unzip ${STAR_CCM_BINARY_ZIP}.zip \
    && cd ${STAR_CCM_BINARY_ZIP} \
    && ./${STAR_CCM_BINARY_ZIP}.sh -i silent \
    && cd .. && rm ${STAR_CCM_BINARY_ZIP}* -rf

ENV PATH=$PATH:/opt/Siemens/${STAR_CCM_VERSION}/STAR-CCM+${STAR_CCM_VERSION}/star/bin


CMD ["/bin/bash"]


