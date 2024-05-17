ARG IMAGE="rocm_gpu:6.0"

FROM ${IMAGE}

ARG LAMMPS_BRANCH="patch_17Apr2024"

WORKDIR /tmp

# Installing LAMMPS
RUN git clone https://github.com/lammps/lammps.git \
  && cd lammps \
  && git checkout ${LAMMPS_BRANCH} \
  && cd .. \
  && mkdir build \
  && cd build \
  && cmake   -DPKG_KOKKOS=on \
        -DPKG_REAXFF=on \
        -DPKG_MANYBODY=on \
        -DPKG_ML-SNAP=on \
        -DPKG_MOLECULE=on \
        -DPKG_KSPACE=on \
        -DPKG_RIGID=on \
        -DBUILD_MPI=on \
        -DCMAKE_INSTALL_PREFIX=/opt/lammps \
        -DMPI_CXX_COMPILER=$(which mpicxx) \
        -DCMAKE_BUILD_TYPE=Release \
        -DKokkos_ENABLE_HIP=on \
        -DKokkos_ENABLE_SERIAL=on \
        -DCMAKE_CXX_STANDARD=14 \
        -DCMAKE_CXX_COMPILER=$(which hipcc) \
        -DKokkos_ARCH_VEGA90A=ON \
        -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON \
        -DCMAKE_CXX_FLAGS="-munsafe-fp-atomics --offload-arch=$GPU_TARGET" \
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
