ARG IMAGE="rocm_gpu:7.0"

FROM ${IMAGE}

ARG LAMMPS_BRANCH="patch_27Jun2024"

WORKDIR /tmp

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libhwloc-dev

# Installing LAMMPS
RUN git clone https://github.com/lammps/lammps.git \
  && cd lammps \
  && git checkout ${LAMMPS_BRANCH} \
  && cd .. \
  && mkdir build \
  && cd build \
  && cmake   \
        -DPKG_KOKKOS=on \
        -DPKG_REAXFF=on \
        -DPKG_MANYBODY=on \
        -DPKG_ML-SNAP=on \
        -DPKG_MOLECULE=on \
        -DPKG_KSPACE=on \
        -DPKG_RIGID=on \
        -DBUILD_MPI=on \
        -DMPI_CXX_SKIP_MPICXX=on \
        -DFFT_KOKKOS=HIPFFT \
        -DCMAKE_INSTALL_PREFIX=/opt/lammps \
        -DMPI_CXX_COMPILER=$(which mpicxx) \
        -DCMAKE_BUILD_TYPE=Release \
        -DKokkos_ENABLE_HIP=on \
        -DKokkos_ENABLE_SERIAL=on \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_COMPILER=$(which hipcc) \
        -DKokkos_ARCH_VEGA90A=ON \
        -DKokkos_ENABLE_HWLOC=on \
        -DLAMMPS_SIZES=smallbig \
        -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON \
        -DCMAKE_CXX_FLAGS="--offload-arch=$AMDGPU_TARGETS" \
        ../lammps/cmake \
    &&   make -j$(nproc) install \
    && cd /tmp/lammps \  
    && mv bench /opt/lammps/bench \
    && mv examples /opt/lammps/examples \
    && mv potentials /opt/lammps/potentials \
    && chmod -R a+rwx /opt/lammps \
    && cd /tmp \
    && rm -rf *  

WORKDIR /opt/lammps/bench 


ENV PATH=$PATH:/opt/lammps/bin

CMD ["/bin/bash"]
