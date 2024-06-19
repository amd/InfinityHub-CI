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
#     spack install specfem3d
#
# You can edit this file again by typing:
#
#     spack edit specfem3d
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

# initial create via:  spack create https://github.com/geodynamics/specfem3d

import os
import sys
from spack import *

class Specfem3d(AutotoolsPackage, ROCmPackage):
    """ SPECFEM3D Cartesian simulates seismic wave propagation at the local or regional scale """

    homepage = "https://github.com/SPECFEM/specfem3d"
    git      = "https://github.com/geodynamics/specfem3d"

    version('4.0.0', branch='devel')

    depends_on('hip')
    depends_on('openmpi +cxx fabrics=ucx ^ucx +rocm +cma  ^hwloc+pci+rocm')
    depends_on('pmix')
    depends_on('scotch')

    variant(
        "amdgpu_model",
        default="default",
        values=("default","MI50", "MI100", "MI210","MI250"),
        description="AMD GPU Model",
    )

    def configure_args(self):
      # HIP_INC should be one level up from hip subdir. ex.: /opt/rocm/include/hip should be coded as /opt/rocm/include.
      print( "HIP_INC="+(self.spec["hip"].prefix)+"/include/")

      gpumodel = str(self.spec.variants['amdgpu_model'].value)
      gputarget= str(self.spec.variants['amdgpu_target'].value)

      print("Specfem3d using amdgpu_model of  {0}".format(gpumodel))
      print("Specfem3d using amdgpu_target of  {0}".format(gputarget))

      gpu_model="Invalid choice"
      if (("gfx906" in gputarget and "MI50" == gpumodel) or ("gfx906" in gputarget and "default" == gpumodel)):
           gpu_model="MI50"
      if (("gfx908" in gputarget and "MI100" == gpumodel) or ("gfx908" in gputarget and "default" == gpumodel)):
           gpu_model="MI100"
      if ("gfx90a" in gputarget and "MI210" == gpumodel):
           gpu_model="MI210"
      if ("gfx90a" in gputarget and "MI250" == gpumodel):
           gpu_model="MI250"

      if (gpu_model=="Invalid choice"):
         print("Error: Specfem3d specified invalid combination of gpu target and architecture")
         sys.exit(1)   

      args = [
              "--with-hip={0}".format(gpu_model),  # MI50,MI100,MI250
              "--with-mpi",
              "--with-rocm=yes",
              "MPIFC=mpif90",
              "HIP_FLAGS=-fPIC -O2 -ftemplate-depth-2048 -fno-gpu-rdc -fdenormal-fp-math=ieee -fcuda-flush-denormals-to-zero -munsafe-fp-atomics",
              "HIP_INC="+(self.spec["hip"].prefix)+"/include/",
              "HIP_LINKING='$(GENCODE_HIP)'" ,
              "HIP_LIBS=hsa-runtime64",
             ]

      return args 


    def setup_run_environment(self, env):
        # UCX dynamically loads libhsa-runtime64.so so we need LD_LIBRARY_PATH set
        # print("SET LD_LIBRARY_PATH to " + self["hsa-rocr-dev"].libs.joined(';'))
        # env.prepend_path("LD_LIBRARY_PATH", self["hsa-rocr-dev"].libs.joined(';'))
        env.prepend_path("LD_LIBRARY_PATH", join_path(self.prefix,"hsa","lib"))
        pass

    def setup_dependent_run_environment(self, env, dependent_spec): 
        # self.setup_run_environment(env)
        env.prepend_path("LD_LIBRARY_PATH", join_path(self.prefix,"hsa","lib"))

    def install(self, spec, prefix):
        print("Running make now ....")
        make()
        print("Running install now ....")
        install_tree('.', prefix)
