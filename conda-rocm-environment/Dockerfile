ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}


WORKDIR /

RUN apt clean && \
    apt-get clean && \
    apt-get -y update --fix-missing --allow-insecure-repositories && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    locales \
    python3 \
    python3-pip \
    wget && \
    cd $HOME && \
    mkdir -p /miniconda3 && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda3/miniconda.sh && \
    bash /miniconda3/miniconda.sh -b -u -p /miniconda3 && \
    rm -rf $HOME/miniconda3/miniconda.sh && \
    . /miniconda3/etc/profile.d/conda.sh && \
    /miniconda3/bin/conda init bash && \
    /miniconda3/bin/conda update --all --yes && \
    /miniconda3/bin/conda install conda-forge::bison && \
    /miniconda3/bin/conda install -c conda-forge mpi4py && \ 
    cd $HOME && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache

WORKDIR /

ENV PATH="/miniconda3/bin:${PATH}"

# Install Additional Apps Below


RUN echo "source activate ${CONDA_ENV_NAME}" >> ${HOME}/.bashrc
