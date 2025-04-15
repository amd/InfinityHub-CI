ARG IMAGE="rocm_gpu:6.4"
FROM ${IMAGE}

ARG NEKRS_BRANCH="v23.0"

ENV NEKRS_HOME=/opt/nekrs
ENV PATH=$NEKRS_HOME/bin:$PATH

RUN apt clean && \
    apt-get clean && \
    apt-get -y update --fix-missing --allow-insecure-repositories && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y  \
    locales \
    gawk libtinfo-dev libfile-copy-recursive-perl libfile-basedir-perl libomp-dev libdrm-dev libtinfo5 libncurses5 mesa-common-dev kmod pciutils libsystemd-dev libpciaccess-dev libxml2-dev libyaml-cpp-dev

RUN mkdir /workspace
RUN chmod -R g+w,o+w /workspace/

COPY files /workspace/files
RUN chmod -R g+w,o+w /workspace/files

WORKDIR /workspace

RUN git clone -b ${NEKRS_BRANCH} https://github.com/Nek5000/nekRS.git && \
    cd /workspace/nekRS && \
    patch 3rd_party/occa/cmake/FindHIP.cmake /workspace/files/FindHIP.patch && \
    patch 3rd_party/occa/src/occa/internal/modes/hip/utils.cpp /workspace/files/utils.patch  && \
    yes '' | CC=mpicc CXX=mpic++ FC=mpif77 ./nrsconfig -DCMAKE_INSTALL_PREFIX=/opt/nekrs && \
    rm -rf /workspace/*
    

WORKDIR /workspace
 
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Default to a login shell
CMD ["bash", "-l"] 
