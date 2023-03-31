# InfinityHub-CI

The purpose of this Repository is to provide a way to build containers similar to what are provided on [AMD's Infinity Hub](https://www.amd.com/en/technologies/infinity-hub).  
Each builds provides parameters to specify different source code branches, release versions of [ROCm](https://github.com/RadeonOpenCompute/ROCm), [OpenMPI](https://github.com/open-mpi/ompi), [UCX](https://github.com/openucx/ucx), and different versions Ubuntu to be build in. 

## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | Container Runtimes | 
| ---- | ---- | ----------------- | ------------ | ------------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> Radeon Instinct MI50(S) | Ubuntu 20.04 <br> UbuntU 22.04 <BR> RHEL8 <br> RHEL9 <br> SLES 15 sp4 | ROCm v5.x compatibility |[Docker Engine](https://docs.docker.com/engine/install/) <br> [Singularity](https://sylabs.io/docs/) |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://docs.amd.com/)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [Testing the ROCm Installation](https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html#testing-the-rocm-installation)

## Applications:
 - [AMD Base Docker Container for GPU-Aware MPI in ROCm applications](/base-gpu-mpi-rocm-docker/)
 - [AMD's Implementation of Gromacs with HIP in Docker](/gromacs-docker/)
 - [HPCG in Docker](/hpcg-docker/)
 - [PETSc in Docker](/petsc-docker/)
 - [rocHPL](/rochpl/)