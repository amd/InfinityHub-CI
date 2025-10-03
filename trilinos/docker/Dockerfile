ARG IMAGE=rocm_gpu:7.0
FROM $IMAGE

# Input options
ARG TRILINOS_BRANCH=develop
ARG ZLIB_BRANCH=v1.2.13
ARG HDF5_BRANCH=hdf5-1_14_3
ARG PNETCDF_BRANCH=checkpoint.1.12.3
ARG NETCDF_BRANCH=v4.9.3
ARG MATIO_BRANCH=v1.5.23 
ARG BOOST_BRANCH=boost-1.80.0
ARG NUM_BUILD_THREADS=32


# Environment setup
RUN DEBIAN_FRONTEND=noninteractive apt install -y ninja-build libblas-dev liblapack-dev libcurl4-openssl-dev

WORKDIR /tmp
ENV ZLIB_ROOT=/opt/zlib \
    CC=mpicc \
    CXX=mpicxx \
    OMPI_CXX=hipcc \
    OMPI_CC=hipcc

# Setup zlib
RUN git clone --recursive -b ${ZLIB_BRANCH} https://github.com/madler/zlib.git \
  && cd zlib \
  && mkdir -p build \
  && cd build \
  && ../configure --prefix=$ZLIB_ROOT \
  && make -j $NUM_BUILD_THREADS install \
  && rm -rf /tmp/zlib

ENV LD_LIBRARY_PATH=$ZLIB_ROOT/lib:$LD_LIBRARY_PATH \
    HDF5_ROOT=/opt/hdf5

# Setup HDF5
RUN git clone --recursive -b ${HDF5_BRANCH} https://github.com/HDFGroup/hdf5.git  \
    && cd hdf5 \
    && ./configure --prefix=$HDF5_ROOT --enable-parallel --with-zlib=$ZLIB_ROOT \
    && make -j $NUM_BUILD_THREADS \
    && make install \
    && cd /tmp \
    && rm -rf hdf5

ENV LD_LIBRARY_PATH=$HDF5_ROOT/lib:$LD_LIBRARY_PATH \
    PNETCDF_ROOT=/opt/pnetcdf

# Setup PNetCDF
RUN git clone --recursive -b ${PNETCDF_BRANCH} https://github.com/Parallel-NetCDF/pnetcdf.git\
  && cd pnetcdf \
  && autoreconf -i \
  && mkdir build \
  && cd build \
  && ../configure --prefix=$PNETCDF_ROOT --enable-shared --disable-fortran \
  && make -j $NUM_BUILD_THREADS install \
  && cd /tmp \
  && rm -rf pnetcdf

ENV LD_LIBRARY_PATH=$PNETCDF_ROOT/lib:$LD_LIBRARY_PATH \
    NETCDF_ROOT=/opt/netcdf

# Setup NetCDF
RUN git clone --recursive -b ${NETCDF_BRANCH} https://github.com/Unidata/netcdf-c.git \
  && cd netcdf-c \
  && autoreconf -i \
  && mkdir -p build \
  && cd build \
  && CFLAGS="-I$ZLIB_ROOT/include -I$HDF5_ROOT/include" \
     CPPFLAGS="-I$ZLIB_ROOT/include -I$HDF5_ROOT/include" \
     LDFLAGS="-L$ZLIB_ROOT/lib -L$HDF5_ROOT/lib" \
     LIBS="-lz -lhdf5" \
     ../configure --prefix=$NETCDF_ROOT --with-hdf5=yes --enable-pnetcd --disable-libxml2 \
  && make -j $NUM_BUILD_THREADS install \
  && cd /tmp \
  && rm -rf netcdf-c

ENV LD_LIBRARY_PATH=$NETCDF_ROOT/lib:$LD_LIBRARY_PATH \
    MATIO_ROOT=/opt/matio

# Setup Matio
RUN git clone --recursive -b ${MATIO_BRANCH} https://github.com/tbeu/matio.git \
  && cd matio \
  && autoreconf -i \
  && mkdir build \
  && cd build \
  && ../configure --prefix=$MATIO_ROOT --with-hdf5=$HDF5_ROOT --with-zlib=$ZLIB_ROOT \
  && make -j $NUM_BUILD_THREADS install \
  && cd /tmp \
  && rm -rf matio

ENV LD_LIBRARY_PATH=$MATIO_ROOT/lib:$LD_LIBRARY_PATH \
    BOOST_ROOT=/opt/boost

# Setup Boost
RUN git clone --recursive -b ${BOOST_BRANCH} https://github.com/boostorg/boost.git \
  && cd boost \
  && ./bootstrap.sh --prefix=$BOOST_ROOT \
  && ./b2 install --prefix=$BOOST_ROOT -j $NUM_BUILD_THREADS \
  && cd /tmp \
  && rm -rf boost

ENV LD_LIBRARY_PATH=$BOOST_ROOT/lib:$LD_LIBRARY_PATH

# Setup Trilinos
RUN git clone --recursive -b $TRILINOS_BRANCH https://github.com/trilinos/trilinos.git \
    && cd trilinos \
    && mkdir build \
    && cd build \
    && cmake \
        -GNinja \
        -D BUILD_SHARED_LIBS=ON \
        -D CMAKE_INSTALL_PREFIX=/opt/trilinos \
        -D CMAKE_BUILD_TYPE=RelWithDebInfo \
        -D CMAKE_CXX_COMPILER=mpicxx \
        -D CMAKE_C_COMPILER=mpicc \
        -D CMAKE_CXX_FLAGS="--offload-arch=$AMDGPU_TARGETS" \
        -D AztecOO_C_FLAGS="-Wno-implicit-function-declaration" \
        -D Trilinos_ENABLE_Fortran=OFF \
        -D Trilinos_ENABLE_ALL_PACKAGES=OFF \
        -D Trilinos_ENABLE_TESTS=OFF \
        -D Trilinos_ENABLE_EXAMPLES=ON \
        -D Trilinos_ENABLE_Kokkos=ON \
        -D Trilinos_ENABLE_Tpetra=ON \
        -D Trilinos_ENABLE_Panzer=ON \
        -D Trilinos_ENABLE_ShyLU_NodeTacho=ON \
        -D Kokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=OFF \
        -D Kokkos_ENABLE_HIP=ON \
        -D Kokkos_ENABLE_SERIAL=ON \
        -D Kokkos_ARCH_VEGA90A=ON \
        -D KokkosKernels_ENABLE_EXPERIMENTAL=ON \
        -D Tpetra_INST_HIP=ON \
        -D Tpetra_ASSUME_GPU_AWARE_MPI=ON \
        -D TPL_ENABLE_MPI=ON \
        -D TPL_ENABLE_ROCBLAS=ON \
        -D TPL_ENABLE_ROCSPARSE=ON \
        -D TPL_ENABLE_ROCSOLVER=ON \
        -D TPL_ENABLE_Boost=ON \
        -D TPL_ENABLE_BoostLib=ON \
        -D TPL_ENABLE_HDF5=ON \
        -D TPL_ENABLE_Matio=ON \
        -D TPL_ENABLE_Netcdf=ON \
        -D TPL_Netcdf_PARALLEL=ON \
        -D Boost_INCLUDE_DIRS=$BOOST_ROOT/include \
        -D Boost_LIBRARY_DIRS=$BOOST_ROOT/lib \
        -D BoostLib_INCLUDE_DIRS=$BOOST_ROOT/include \
        -D BoostLib_LIBRARY_DIRS=$BOOST_ROOT/lib \
        -D HDF5_INCLUDE_DIRS=$HDF5_ROOT/include \
        -D HDF5_LIBRARY_DIRS=$HDF5_ROOT/lib \
        -D Matio_INCLUDE_DIRS=$MATIO_ROOT/include \
        -D Matio_LIBRARY_DIRS=$MATIO_ROOT/lib \
        -D Netcdf_INCLUDE_DIRS="$NETCDF_ROOT/include;$PNETCDF_ROOT/include" \
        -D Netcdf_LIBRARY_DIRS="$NETCDF_ROOT/lib;$PNETCDF_ROOT/lib" \
        .. \
    && ninja -j $NUM_BUILD_THREADS install \
    && rm -rf /tmp/trilinos 

# Set run command
CMD ["bash", "-c"]

