ARG IMAGE="rocm_gpu:6.0
FROM ${IMAGE}

ENV NEKRS_HOME=/opt/nekrs
ENV PATH=$NEKRS_HOME/bin:$PATH

RUN mkdir /workspace

WORKDIR /workspace

RUN git clone https://github.com/Nek5000/nekRS.git && \
    cd /workspace/nekRS && \
    CC=mpicc CXX=mpic++ FC=mpif77 ./nrsconfig -DCMAKE_INSTALL_PREFIX=/opt/nekrs && \

WORKDIR /workspace

RUN rm -rf /workspace/nekRS 

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Default to a login shell
CMD ["bash", "-l"] 
