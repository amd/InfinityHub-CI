# CP2K on AMD GPUs — Spack-based recipe

## Overview

CP2K is a quantum chemistry and solid state physics software package that can perform atomistic simulations of solid state, liquid, molecular, periodic, material, crystal, and biological systems. CP2K provides a general framework for different modeling methods such as [DFT](http://en.wikipedia.org/wiki/Density_functional_theory) using the mixed [Gaussian and plane waves approaches GPW and GAPW](https://www.cp2k.org/quickstep#gpw). Supported theory levels include DFTB, LDA, GGA, MP2, RPA, semi-empirical methods (AM1, PM3, PM6, RM1, MNDO, …), and classical force fields (AMBER, CHARMM, …). CP2K can do simulations of molecular dynamics, metadynamics, Monte Carlo, Ehrenfest dynamics, vibrational analysis, core level spectroscopy, energy minimization, and transition state optimization using NEB or dimer method. Detailed overview of features may be found at the [CP2K site](https://www.cp2k.org/features).

CP2K is written in Fortran 2008 and can be run efficiently in parallel using a combination of multi-threading, MPI, and HIP/CUDA. The CP2K software package is [freely available](https://www.cp2k.org/download) under the GPL license at https://www.cp2k.org.

For more information about CP2K, see www.cp2k.org.

The latest CP2K review, as of **May 2020**, can be found at **[The Journal of Chemical Physics 10.1063/5.0007045](https://doi.org/10.1063/5.0007045).**

This repository contains a build & run recipe for CP2K with **AMD ROCm**
acceleration, in three flavors that share the same Spack-based build script:

- [`baremetal/`](baremetal/) — direct host install via Spack
- [`docker/`](docker/) — same recipe, packaged as a Docker image
- [`singularity/`](singularity/) — same recipe as a Singularity image (for hosts with Singularity/Apptainer but no Docker)

All flavors source their build logic from [`shared/cp2k_build.sh`](shared/cp2k_build.sh).

## Layout

```
.
├── shared/
│   ├── cp2k_build.sh      # single source of truth for the Spack build
│   ├── close.sh           # GPU binder (ROCR_VISIBLE_DEVICES)
│   └── patches/
│       └── 0001-Add-AMD-MI350-gfx950-support-to-CP2K.patch
├── baremetal/
│   ├── build_cp2k.sh      # thin wrapper around shared/cp2k_build.sh
│   └── scripts/           # mpirun + SLURM launchers, NUMA-aware
├── docker/
│   ├── Dockerfile         # ROCm base + shared/cp2k_build.sh
│   ├── build_cp2k.sh      # `docker build` wrapper
│   └── scripts/           # `docker run` launchers
└── singularity/
    ├── cp2k.def           # ROCm base + shared/cp2k_build.sh
    ├── build_cp2k.sh      # `singularity build` wrapper
    └── scripts/           # `singularity exec` launchers
```

## System requirements

| CPUs | GPUs | Operating Systems | ROCm |
|---|---|---|---|
| x86_64 | AMD Instinct MI100 / MI200 / MI300 / MI350 | Ubuntu 22.04 / 24.04, RHEL 8 / 9, SLES 15 SP4 | ROCm 7.x |

For ROCm installation, see the [ROCm Documentation](https://rocm.docs.amd.com).

Recommended resources for a build: 50+ GB free disk, 32+ GB RAM, and
internet access during the build (Spack and source tarballs). Build time is
typically 1–3 hours. Flavor-specific prerequisites (host tooling, Docker,
Singularity/Apptainer) are listed in each flavor's README.

## What the build does

`shared/cp2k_build.sh` produces a self-contained Spack tree that includes:

- A pinned Spack (`v1.1.1`) and `spack-packages` repo (`v2026.03.0`)
- A small in-tree patch that registers `gfx950`/Mi350 in the CP2K Spack
  package (always applied; harmless on other targets)
- `gcc@14.3.0` built by Spack and used to compile everything else
- The full MPI stack (`ucx@1.20.0`, `ucc@1.7.0`, `openmpi@5.0.10`) built by
  Spack with ROCm + OFED enabled
- ROCm itself consumed as Spack externals from `${ROCM_PATH}` (no source
  build of ROCm)
- CP2K `2026.1` with all the usual GPU-accelerated dependencies:
  `cosma`, `costa`, `dbcsr`, `fftw`, `hdf5`, `libvdwxc`, `netlib-scalapack`,
  `sirius`, `spfft`, `spla`, `umpire`, plus `boost`, `dftd4`, `libint`,
  `libxc`, `libxsmm@1.17`, `openblas`, `pugixml`, `simple-dftd3`, `spglib`,
  `tiled-mm`, `toml-f`, etc.

Defaults target an MI350X / Zen5 / ROCm 7.2 host.

Configure a git identity first (`git config --global user.name`/`user.email`); it
is used by `git am` when applying the gfx950 patch.

### Build configuration

All flavors read the same build knobs (environment variables consumed by
`shared/cp2k_build.sh`). The most useful, shared across flavors:

| Variable | Default | Notes |
|---|---|---|
| `GPU_ARCH` | `gfx950` | `gfx908` (MI100), `gfx90a` (MI200), `gfx942` (MI300), `gfx950` (MI350) |
| `CPU_ARCH` | `zen5` | Any Spack microarch (e.g. `zen3`, `zen4`) |
| `ROCM_VERSION` | `7.2.0` | Version reported to Spack for the ROCm externals |
| `ROCM_PATH` | `/opt/rocm-${ROCM_VERSION}` | Filesystem path to ROCm |
| `GCC_VERSION` | `14.3.0` | GCC built by Spack and used as the CP2K compiler |
| `SPACK_BRANCH` | `v1.1.1` | Spack version |
| `SPACK_PACKAGES_TAG` | `v2026.03.0` | `spack/spack-packages` tag |
| `BUILD_JOBS` | `32` | `spack install -j` |

```bash
GPU_ARCH=gfx942 CPU_ARCH=zen3 ROCM_VERSION=7.0.0 ./baremetal/build_cp2k.sh
```

Each flavor adds its own knobs (e.g. `BUILD_ROOT` for baremetal, `IMAGE_*`
for docker, `SIF_IMAGE` for singularity) — see the flavor READMEs.

> **Disclaimer**: This recipe has only been validated with the default
> values. Different GPU targets, ROCm versions, or build options may cause
> build failures or suboptimal performance.

## Build recipes

- [Bare metal](baremetal/README.md)
- [Docker](docker/README.md)
- [Singularity / Apptainer](singularity/README.md)

## Running CP2K benchmarks

Each flavor ships the same two launcher scripts under its own `scripts/`
directory for two reference benchmarks pulled from the upstream CP2K source
tree:

| Benchmark | Script name (identical across flavors) |
|---|---|
| [`QS_DM_LS / H2O-dft-ls.NREP2`](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_DM_LS/H2O-dft-ls.NREP2.inp) | `cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run` |
| [`QS_mp2_rpa / 32-H2O`](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/) ([init](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-PBE-TZ.inp) + [solver](https://github.com/cp2k/cp2k/blob/master/benchmarks/QS_mp2_rpa/32-H2O/H2O-32-RI-dRPA-TZ.inp)) | `cp2k_QS_mp2_rpa_32-H2O.run` |

The baremetal, docker, and singularity scripts share the same filenames,
SBATCH headers, lowercase topology variables, and EXPNAME /
output-directory layout. They double as SLURM batch jobs (`sbatch …`) and
as plain interactive scripts (`./…`). All launchers use OpenMPI's
NUMA-aware `--map-by ppr:N:numa:PE=T` mapping together with
[`shared/close.sh`](shared/close.sh), which assigns one GPU per rank via
`ROCR_VISIBLE_DEVICES`.

### Topology variables

The defaults target a single node with 256 logical CPUs, 128 physical CPU
cores, 8 NUMA domains, and 8 GPUs. Override via environment variables
(lowercase, matching SLURM convention) before invoking the script:

| Variable | Default | Notes |
|---|---|---|
| `lcpus_per_node` | 256 | Logical CPUs on the node |
| `physcpus_per_node` | 128 | Physical CPU cores |
| `numa_per_node` | 8 | Must match `numactl -H`; a wrong value breaks the `--map-by ppr:N:numa` binding |
| `gpus_per_node` (or `GPUS_PER_NODE`) | 8 | GPUs per node |
| `nthreads_init` (RPA only) | `physcpus_per_node / numa_per_node` | Init-stage OpenMP threads |
| `arch` | `mi350x` | Used in the output directory name |

Per-rank counts come from `SLURM_NTASKS` / `SLURM_NTASKS_PER_NODE` /
`SLURM_CPUS_PER_TASK` when available, otherwise from the SBATCH defaults.
Set `numa_per_node` to the value reported by `numactl -H` if the node does
not have the default 8 domains (for example `numa_per_node=2` on a 2-domain
node):

```bash
SLURM_NTASKS=16 gpus_per_node=8 numa_per_node=<domains> \
    ./baremetal/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
```

### MPI / UCX defaults

The launchers (and the container images) set the same OpenMPI/UCX runtime
defaults:

```
OMPI_MCA_pml=ucx
OMPI_MCA_osc=ucx
OMPI_MCA_coll_ucc_enable=1
OMPI_MCA_coll_ucc_priority=100
UCX_TLS=self,sm,rocm_copy,rocm_ipc,ud_x
UCX_MAX_RNDV_RAILS=1
HSA_ENABLE_SDMA=0
HSA_ENABLE_IPC_MODE_LEGACY=1
HIP_MEM_POOL_SUPPORT=1
```

Override any of them via the environment (baremetal/singularity) or `-e VAR=...`
on `docker run` (docker).

### Figure of merit

The figure of merit (FOM) is the total elapsed run time in seconds. Each
launcher prints it as `FOM: <N> seconds`, taken from the last field of the
`CP2K` timing line in the output file. To read it manually:

```bash
grep 'CP2K             ' <benchmark>.out | tail -n 1
```

### GPU-to-GPU communication

The DFT launcher (`cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run`, in every flavor's
`scripts/`) sets `DBCSR_USE_ACC_G2G=1`, which enables GPU-to-GPU
communication and improves multi-GPU DFT performance. It is not set
globally and is not used for the RPA benchmark. To disable it for a
comparison run, pass `DBCSR_USE_ACC_G2G=0` before invoking the script.

## Licensing Information

Your use of this application is subject to the terms of the applicable
component-level license identified below. To the extent any subcomponent in
this container requires an offer for corresponding source code, AMD hereby
makes such an offer for corresponding source code form, which will be made
available upon request. By accessing and using this application, you are
agreeing to fully comply with the terms of this license. If you do not
agree to the terms of this license, do not access or use this application.

| Package | License | URL |
|---|---|---|
| Ubuntu | Creative Commons CC-BY-SA Version 3.0 UK License | [Ubuntu Legal](https://ubuntu.com/legal) |
| CMAKE | OSI-approved BSD-3 clause | [CMake License](https://cmake.org/licensing/) |
| OpenMPI | BSD 3-Clause | [OpenMPI License](https://www-lb.open-mpi.org/community/license.php) |
| OpenUCX | BSD 3-Clause | [OpenUCX License](https://openucx.org/license/) |
| ROCm | Custom/MIT/Apache V2.0/UIUC OSL | [ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html) |
| CP2K | GNU GPL Version 2 | [CP2k License](https://github.com/cp2k/cp2k/blob/master/LICENSE) |
| Spack | Apache-2.0 OR MIT | [Spack License](https://github.com/spack/spack/blob/develop/LICENSE-APACHE) |
| OpenBlas | BSD 3-Clause | [OpenBlas License](https://github.com/xianyi/OpenBLAS/blob/develop/LICENSE) |
| COSMA | BSD 3-Clause | [COSMA License](https://github.com/eth-cscs/COSMA/blob/master/LICENSE) |
| Libxsmm | BSD 3-Clause | [Libxsmm License](https://libxsmm.readthedocs.io/en/latest/LICENSE/) |
| Libxc | MPL v2.0 | [Libxc License](https://github.com/ElectronicStructureLibrary/libxc) |
| SpLA | BSD 3-Clause | [SpLA License](https://github.com/eth-cscs/spla/blob/master/LICENSE) |
| DBCSR | GPL-2.0 | [DBCSR License](https://github.com/cp2k/dbcsr) |
| SIRIUS | BSD 3-Clause | [SIRIUS License](https://github.com/electronic-structure/SIRIUS) |

Additional third-party content in this container may be subject to
additional licenses and restrictions. The components are licensed to you
directly by the party that owns the content pursuant to the license terms
included with such content and is not licensed to you by AMD. ALL LINKED
THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD "AS IS" WITHOUT A WARRANTY OF
ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO
CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU
ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE
FROM YOUR USE OF THE CONTAINER.

## Disclaimer

The information contained herein is for informational purposes only, and is
subject to change without notice. In addition, any stated support is planned
and is also subject to change. While every precaution has been taken in the
preparation of this document, it may contain technical inaccuracies,
omissions and typographical errors, and AMD is under no obligation to
update or otherwise correct this information. Advanced Micro Devices, Inc.
makes no representations or warranties with respect to the accuracy or
completeness of the contents of this document, and assumes no liability of
any kind, including the implied warranties of noninfringement,
merchantability or fitness for particular purposes, with respect to the
operation or use of AMD hardware, software or other products described
herein. No license, including implied or arising by estoppel, to any
intellectual property rights is granted by this document. Terms and
limitations applicable to the purchase or use of AMD's products are as set
forth in a signed agreement between the parties or in AMD's Standard Terms
and Conditions of Sale.

## Notices and Attribution

© 2022-2026 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD
Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are
trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of
Docker, Inc. in the United States and/or other countries. Docker, Inc. and
other parties may also have trademark rights in other terms used herein.
Linux® is the registered trademark of Linus Torvalds in the U.S. and other
countries.

All other trademarks and copyrights are property of their respective owners
and are only mentioned for informative purposes.
