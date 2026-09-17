# CP2K — Bare Metal Build

This document describes how to build CP2K with ROCm support directly on a
host using Spack. The build is driven by
[`../shared/cp2k_build.sh`](../shared/cp2k_build.sh); this directory just
provides a thin wrapper and a set of NUMA-aware run scripts.

## System requirements

Supported CPUs/GPUs/OS and recommended resources are in the
[main README](../README.md#system-requirements).

### Tools the host must have

The build script bootstraps almost everything via Spack, including a fresh
GCC toolchain. The host only needs the things Spack itself depends on:

| Tool | Why |
|---|---|
| `git` | Cloning Spack and `spack-packages` |
| `make`, `patch`, `tar`, `gzip`, `bzip2`, `xz` | Spack's bootstrap |
| `python3` | Spack |
| A working C/C++ compiler (`gcc` or `clang`) | To bootstrap GCC 14.3.0 |
| ROCm | Installed at `${ROCM_PATH}` (default `/opt/rocm-${ROCM_VERSION}`) |

UCX, UCC, OpenMPI, GCC, BLAS, FFT, etc. are **all built by Spack**.

Configure a git identity before building (used by `git am` for the gfx950 patch):

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Quick start

```bash
cd /path/to/cp2k-recipe/baremetal

# Build everything (defaults: MI350X / Zen5 / ROCm 7.2)
./build_cp2k.sh

# Use it
source cp2k-baremetal/spack_git/share/spack/setup-env.sh
spack env activate cp2k
spack load cp2k
cp2k.psmp --version
```

The build creates a single self-contained directory `./cp2k-baremetal/`
with `spack_git/`, `spack-packages_git/`, `install/`, `environments/`,
`spack_stage/`, plus a convenience symlink `cp2k -> <CP2K install prefix>`.

## Configuration

The shared build knobs (`GPU_ARCH`, `CPU_ARCH`, `ROCM_VERSION`, `ROCM_PATH`,
`GCC_VERSION`, `SPACK_BRANCH`, `SPACK_PACKAGES_TAG`, `BUILD_JOBS`) and the
validation disclaimer are documented in the
[main README](../README.md#build-configuration). Baremetal-specific knobs:

| Variable | Default | Notes |
|---|---|---|
| `BUILD_ROOT` | `${PWD}/cp2k-baremetal` | Where the Spack tree is created |
| `SPACK_FETCH_JOBS` | `4` | `spack install -p` |

Examples:

```bash
# MI300X on Zen3 with ROCm 7.0
GPU_ARCH=gfx942 CPU_ARCH=zen3 ROCM_VERSION=7.0.0 \
    ./build_cp2k.sh

# Custom install location
BUILD_ROOT=/opt/cp2k-baremetal ./build_cp2k.sh

# Smaller machine
BUILD_JOBS=8 ./build_cp2k.sh
```

## Activating the environment afterwards

```bash
source cp2k-baremetal/spack_git/share/spack/setup-env.sh
spack env activate cp2k
spack load cp2k
which cp2k.psmp     # cp2k-baremetal/install/.../cp2k.../bin/cp2k.psmp
```

## Running benchmarks

The launchers in [`scripts/`](scripts/) use OpenMPI's NUMA-aware
`--map-by ppr:N:numa:PE=T` mapping together with
[`../shared/close.sh`](../shared/close.sh), which binds one GPU per rank
via `ROCR_VISIBLE_DEVICES`.

| Script | Benchmark |
|---|---|
| `scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run` | `QS_DM_LS / H2O-dft-ls.NREP2` |
| `scripts/cp2k_QS_mp2_rpa_32-H2O.run` | `QS_mp2_rpa / 32-H2O` (init + solver) |

Both scripts double as SLURM batch scripts (just `sbatch` them) and as
plain interactive scripts (just `./` them) — the SBATCH directives are
shell comments when run outside SLURM, and every `SLURM_*` variable has a
sensible default. They will clone the CP2K source into `../cp2k_repo/` on
first run to get the benchmark inputs.

Topology variables (`numa_per_node`, `gpus_per_node`, etc.), the MPI/UCX
defaults, the figure of merit, and the `DBCSR_USE_ACC_G2G` option are shared
across flavors and documented in the
[main README](../README.md#running-cp2k-benchmarks). Set `numa_per_node` to
your node's actual NUMA domain count (`numactl -H`).

Examples:

```bash
# DFT, interactive
./scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run

# DFT, smaller box (4 GPUs, 8 ranks)
SLURM_NTASKS=8 numa_per_node=4 gpus_per_node=4 \
    ./scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run

# RPA, interactive
./scripts/cp2k_QS_mp2_rpa_32-H2O.run

# Either as a SLURM job (set numa_per_node to the node's NUMA count)
sbatch --export=ALL,numa_per_node=<domains> ./scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
sbatch --export=ALL,numa_per_node=<domains> ./scripts/cp2k_QS_mp2_rpa_32-H2O.run
```

Output goes under
`outputs/<benchmark>/<experiment>/<arch>_N<nodes>.n<ranks>.t<threads>.g<gpus>_<jobid>/...`
and each script prints the [figure of merit](../README.md#figure-of-merit)
from the resulting `*.out`.

## Troubleshooting

### Build fails to find ROCm

```
ERROR: ROCM_PATH=/opt/rocm-7.2.0 does not exist.
```

Set `ROCM_PATH` (or `ROCM_VERSION`) to point to your ROCm install, e.g.:

```bash
ROCM_PATH=/opt/rocm ROCM_VERSION=7.0.0 ./build_cp2k.sh
```

### Patch fails to apply

The gfx950 patch is applied to the upstream `spack-packages` checkout the
first time the build runs. If you delete `BUILD_ROOT/spack-packages_git/`
and re-run, it will be recloned and re-patched. If the upstream
`spack-packages` tag has moved on and the patch context no longer matches,
remove the patch from `shared/patches/` (gfx950 may already be supported
upstream) and re-run.

### `cp2k.psmp` not found after build

Make sure you sourced the right `setup-env.sh`:

```bash
source cp2k-baremetal/spack_git/share/spack/setup-env.sh
spack env activate cp2k
spack load cp2k
```

### Rebuilding from scratch

```bash
rm -rf cp2k-baremetal
./build_cp2k.sh
```

## Files created by the build

```
cp2k-baremetal/
├── spack_git/              # Pinned Spack checkout
├── spack-packages_git/     # Pinned spack-packages checkout (patched)
├── install/                # Spack install tree (everything)
├── environments/cp2k/      # Generated Spack env
├── spack_stage/            # Build stage
└── cp2k -> .../install/.../cp2k-2026.1-...
```
