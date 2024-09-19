# InfinityHub-CI

The purpose of this Repository is to provide a way to build containers similar to what are provided on [AMD's Infinity Hub](https://www.amd.com/en/technologies/infinity-hub).  
Each builds provides parameters to specify different source code branches, release versions of [ROCm](https://github.com/RadeonOpenCompute/ROCm), [OpenMPI](https://github.com/open-mpi/ompi), [UCX](https://github.com/openucx/ucx), and different versions Ubuntu to be build in. 

## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
|---- |---- |----------------- |------------ |------------------ | 
| X86_64 CPU(s) |[AMD Instinct MI300A/X APU/GPU(s) <br> AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s)](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-gpus) | [Ubuntu <br> RHEL <br>  SLES  <br> Oracel Linux](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-operating-systems) | [ROCm Latest](https://rocm.docs.amd.com/en/latest/) | [Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)

## Applications:
|Application|Builds|ROCm Version|Domains|
|---|---|---|---|
|[AMD ROCm with GPU-Aware MPI Container](/base-gpu-mpi-rocm-docker/)|<ul><li>[Docker](/base-gpu-mpi-rocm-docker/)</li></ul>|6.2|<ul><li>Tools</li><li>Libraries</li></ui>|
|[AMD's implementation of Gromacs with HIP](/gromacs/)|<ul><li>[Baremetal](/gromacs/baremetal/)</li><li>[Docker](/gromacs/docker/)</li></ul>|latest|<ul><li>Molecular Dynamics</li></ul>|
|[Ansys Fluent](/ansys-fluent/)|<ul><li>[Baremetal](/ansys-fluent/baremetal/)</li><li>[Docker](/ansys-fluent/docker/)</li></ul>|latest|<ul><li>Computational Fluid Dynamics</li></ul>|
|[Amber](/amber/)|<ul><li>[Amber Details](/amber/)</li></ul>|latest|<ul><li>Molecular Dynamics</li></ul>|
|[BabelStream](/babelstream/)|<ul><li>[Container Instructions](/babelstream/)|5.3|<ul><li>Benchmark</li></ul>|
|[Cholla](/cholla/)|<ul><li>[Baremetal](/cholla/baremetal/)</li><li>[Docker](/cholla/docker/)</li></ul>|latest|<ul><li>Astrophysics</li></ul>|
|[Chroma](/chroma/)|<ul><li>[Docker](/chroma/docker/)</li></ul>|6.1.1|<ul><li>Physics</li></ul>|
|[CP2K](/cp2k/)|<ul><li>[Baremetal](/cp2k/baremetal/)</li><li>[Docker](/cp2k/docker/)</li></ul>|latest|<ul><li>Electronic Structure</li></ul>|
|[Grid](/grid/)|<ul><li>[Docker](/grid/docker/)</li></ul>|latest|<ul><li>Physics</ul>|
|[HPCG](/hpcg/)|<ul><li>[Baremetal](/hpcg/baremetal/)</li><li>[Docker](/hpcg/docker/)</li></ul>|latest|<ul><li>Benchmark</li></ul>|
|[Kokkos](/kokkos/)|<ul><li>[Docker](/kokkos/docker/)</li></ul>|latest|<ul><li>Tools</li><li>Libraries</li></ul>|
|[LAMMPS](/lammps/)|<ul><li>[Baremetal](/lammps/baremetal/)</li><li>[Docker](/lammps/baremetal/)</li></ul>|latest|<ul><li>Molecular Dynamics</li></ul>|
|[MILC](/milc/)|<ul><li>[Docker](/milc/docker/)</li></ul>|latest|<ul><li>Physics</li></ul>|
|[Mini-HACC](/minihacc/)|<ul><li>[Container Instructions](/minihacc/)|5.3|<ul><li>Astrophysics</li></ul>|
|[MPAS](/mpas/)|<ul><li>[Baremetal](/mpas/)</li></ul>|latest|<ul><li>Climate</li><li>Weather</li></ul>|
|[NAMD](/namd/)|<ul><li>[Container Instructions](/namd/)</li></ul>|4.3/4.5|<ul><li>Molecular Dynamics</li></ul>|
|[NEKO](/neko/)|<ul><li>[Docker](/neko/docker/)</li></ul>|latest|<ul><li>Computational Fluid Dynamics</li></ul>|
|[nekRS](/nekrs/)|<ul><li>[Docker](/nekrs/docker/)</li></ul>|latest|<ul><li>Computational Fluid Dynamics</li></ul>|
|[NWChem](/nwchem/)|<ul><li>[Container Instructions](/nwchem/)</li></ul>|5.3|<ul><li>Computational Chemistry</li></ul>|
|[OpenFOAM](/openfoam/)|<ul><li>[Docker](/openfoam/docker/)</li></ul>|latest|<ul><li>Computational Fluid Dynamics</li></ul>|
|[OpenMM](/openmm/)|<ul><li>[Docker](/openmm/docker/)</li></ul>|5.7|<ul><li>Molecular Dynamics</li></ul>|
|[PeleC](/pelec/)|<ul><li>[Docker](/pelec/docker/)</li></ul>|latest|<ul><li>Computational Fluid Dynamics</li></ul>|
|[PETSc](/petsc/)|<ul><li>[Docker](/petsc/docker/)</li></ul>|latest|<ul><li>Tools</li><li>Libraries</li></ul>|
|[PIConGPU](/picongpu/)|<ul><li>[Docker](/picongpu/docker/)</li></ul>|latest|<ul><li>Physics</li></ul>|
|[PyFR](/pyfr/)|<ul><li>[Docker](/pyfr/docker/)</li></ul>|latest|<ul><li>Tools</li><li>Libraries</li></ul>|
|[QUDA](/quda/)|<ul><li>[Docker](/quda/docker/)</li></ul>|latest|<ul><li>Computational Chemistry</li></ul>|
|[QMCPACK](/qmcpack/)|<ul><li>[Docker](/qmcpack/docker/)</li></ul>|latest|<ul><li>Quantum Monte Carlo Simulation</li></ul>|
|[RAJA](/raja/)|<ul><li>[Docker](/raja/docker/)</li></ul>|latest|<ul><li>Tools</li><li>Libraries</li></ul>|
|[RELION](/relion/)|<ul><li>[Container Instructions](/relion/)</li></ul>|5.3|<ul><li>Electronic Structure</li></ul>|
|[rocHPL](/rochpl/)|<ul><li>[Docker](/rochpl/docker/)</li><li>[Spack Docker](/rochpl/docker-spack/)</li><li>[Spack](/rochpl/spack/)</li></ul>|latest|<ul><li>Benchmark</li></ul>|
|[rocHPL-MxP](/hpl-mxp/)|<ul><li>[Docker](/hpl-mxp/docker/)</li></ul>|latest|<ul><li>Benchmark</li></ul>|
|[SPECFEM3D - Cartesian](/specfem3d/)|<ul><li>[Spack Docker](/specfem3d/docker/)</li></ul>|latest|<ul><li>Geophysics</li></ul>|
|[Trilinos](/trilinos/)|<ul><li>[Docker](/trilinos/docker/)</li></ul>|latest|<ul><li>Tools</li><li>Libraries</li></ul>|
|[VLLM](/vllm/)|<ul><li>[Docker](/vllm/docker/)</li></ul>|latest|<ul><li>Tools</li><li>LLM</li></ul>|
