# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# ----------------------------------------------------------------------------
# If you submit this package back to Spack as a pull request,
# please first remove this boilerplate and all FIXME comments.
#
# This is a template package file for Spack.  We've put "FIXME"
# next to all the things you'll want to change. Once you've handled
# them, you can save this file and test your package like this:
#
#     spack install rochpl
#
# You can edit this file again by typing:
#
#     spack edit rochpl
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack.package import *


class Rochpl(CMakePackage,ROCmPackage):
    """Build the AMD GPU based rocHPL application"""

    homepage = "https://github.com/ROCmSoftwarePlatform/rocHPL"
    url = "https://github.com/ROCmSoftwarePlatform/rocHPL.git"

    maintainers = ["doscherda", ""]

    version("main", git="https://github.com/ROCmSoftwarePlatform/rocHPL.git")

    depends_on("mpi@3.1:")
    depends_on("ucx@1.13.1 +rocm ")
    depends_on("openmpi@4.1.4  fabrics=ucx")

    depends_on("hip@5.3.3")
    depends_on("rocm-cmake")
    depends_on("amdblis +cblas")
    depends_on("rocblas")
    depends_on("roctracer-dev")
    depends_on("rocprofiler-dev")
    depends_on("llvm-amdgpu +llvm_dylib +rocm-device-libs -openmp")


    @property
    def headers(self):
       return find_headers('rochpl', root=self.home.include, recursive=False)

    def mpi_home(self):
       return self.prefix.openmpi


    def cmake_args(self):
        mpidir=self.mpi_home()

        amdblisLibs=";".join(self.spec["amdblis"].libs.libraries)

        amdblis=self.spec["amdblis"].prefix

        hip=self.spec["hip"].prefix

        rocblas=self.spec["rocblas"].prefix

        roctracer_dev=self.spec["roctracer-dev"].prefix

        # CMAKE_MODULE_PATH  points to dir w/FindHIP.cmake
        # ROCBLAS_DIR points to cmake dir for rocblas
        # BLAS_LIBRARIES points to rocblas and amdblis libs
        # HPL_MPI_DIR location of mpicc
        # ROCM_PATH location of roctracer

        args = [
                "-DROCM_PATH="+self.spec["roctracer-dev"].prefix,
                "-DROCM_PKGTYPE=DEB",
                "-DROCBLAS_DIR="+rocblas+"/lib/cmake/rocblas",
                "-DBLAS_LIBRARIES="+rocblas+"/lib/librocblas.so"+";"+amdblisLibs,
                "-DCMAKE_MODULE_PATH="+hip+"/hip/cmake",
                "-DHPL_MPI_DIR="+self.spec["openmpi"].prefix,
                "-DHIP_HIPCC_FLAGS=-I "+roctracer_dev+"/roctracer/include",
                "-DCMAKE_CXX_FLAGS=-I "+roctracer_dev+"/roctracer/include",
                # optional args:
                "-DHIP_PLATFORM=amd",
                "-DHPL_VERBOSE_PRINT=ON",
                "-DHPL_PROGRESS_REPORT=ON",
                "-DHPL_DETAILED_TIMING=ON",
               ]
        return args
