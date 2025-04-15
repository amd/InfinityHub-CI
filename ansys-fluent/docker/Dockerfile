ARG IMAGE=rocm_gpu:6.4

FROM ${IMAGE}

ARG FLUENT_TAR="fluent.24.2.lnamd64.tgz"
ARG FLUENT_VERSION="242"
ARG ANSYSLMD_LICENSE_FILE


ENV OPENMPI_ROOT=${OMPI_PATH}

#Ansys requiermen
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        p7zip-full \
        apt-utils \
        dialog \
        lsb-core \
        libgl1 \
        libglu1-mesa \
        libxm4 \
        libxi6 \
        openssh-server \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
        libxcb-render0 \
        libxcb-shape0 \
        libxcb-util1 \
        libxcb-xinerama0 \
        libxcb-xkb1 \
        libxkbcommon-x11-0 \
        libxkbcommon0 \
    && apt-get clean


# Setup Ansys Fluent
# Currently, Ansys provided us the Fluent SW as a .tgz file. This file needs to be located in ./source directory. 
# No installation process needed.  Just copy this file into this container and unzip it in the desired directory.

WORKDIR /opt

# Bring in the Ansys-fluent SW.  ADD will pull in and extract the compressed file and place them in the current directory
COPY sources/${FLUENT_TAR} .

RUN tar -xzvf ${FLUENT_TAR} --no-same-owner \
    && rm ${FLUENT_TAR} \
    && chmod -R 777 /opt/ansys_inc/

ENV PATH=/opt/ansys_inc/v${FLUENT_VERSION}/fluent/bin:/opt/ansys_inc/v${FLUENT_VERSION}/fluent/bench/bin:$PATH
ENV ANSGPU_OVERRIDE=1

# Link python to python3
RUN ln -s /opt/ansys_inc/v${FLUENT_VERSION}/commonfiles/CPython/3_10/linx64/Release/python/bin/python /usr/bin/python

WORKDIR /benchmark

# Using Ansys License Server to obtain the Ansys license 
ENV ANSYSLMD_LICENSE_FILE=${ANSYSLMD_LICENSE_FILE}

##################################################################################################################
# If use the temp license file, instead of License Server,
# comment out above "ANSYSLMD_LICENSE_FILE=" line and un-comment this section to copy flex license file in
# and enable flex license
 
#COPY sources/ansyslmd.ini /opt/ansys_inc/shared_files/licensing/
#ENV ANSYSLI_ELASTIC=1

# SSL shenanigans (fixes elastic issue)
#ENV capath=/etc/ssl/certs
#ENV cacert=/etc/ssl/certs/ca-certificates.crt

#RUN echo "capath=/etc/ssl/certs" >> $HOME/.curlrc
#RUN echo "cacert=/etc/ssl/certs/ca-certificates.crt" >> $HOME/.curlrc

#RUN cd /etc/ssl/certs && wget http://curl.haxx.se/ca/cacert.pem && ln -s cacert.pem ca-bundle.crt
################################################################################################################


CMD ["/bin/bash"]

