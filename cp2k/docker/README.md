# CP2K — Container Build

This document describes how to build CP2K with ROCm support as a Docker
container. The image is produced by [`../shared/cp2k_build.sh`](../shared/cp2k_build.sh)
running inside a ROCm base image; the Dockerfile here is intentionally a
thin layer over that script so the recipe is identical to the
[`baremetal/`](../baremetal/) build.

## Requirements

- Git
- Docker (or Podman) with BuildKit recommended
- Internet access during the build (Spack and source tarballs)
- ~50 GB free disk space (Spack build stage is large)

Supported CPUs/GPUs/OS are in the
[main README](../README.md#system-requirements).

## What the build does

1. Starts from a ROCm base image (default: `rocm/dev-ubuntu-24.04:7.2-complete`).
2. Installs the minimal system tooling Spack needs to bootstrap (no UCX,
   UCC, OpenMPI, or GCC are pre-installed via apt — Spack builds them).
3. COPYs `shared/` into the image and runs `shared/cp2k_build.sh`.
4. Symlinks the resulting CP2K install at `/opt/cp2k`.

The complete build recipe (Spack version, GCC version, MPI stack,
dependencies, gfx950 patch) lives in `shared/cp2k_build.sh` and is shared
verbatim with the baremetal flow.

## Quick start

Build from the repository root (the Dockerfile lives in `docker/` but the
build context must be the repo root so `shared/` is available):

```bash
cd /path/to/cp2k-recipe
./docker/build_cp2k.sh
```

That defaults to:
- `gfx950` (MI350X) GPU target
- `zen5` CPU microarch
- ROCm `7.2.0`
- `gcc@14.3.0`, `openmpi@5.0.10`, `ucx@1.20.0`, `ucc@1.7.0` — all built by
  Spack

## Configuration

The build wrapper forwards environment variables to the Dockerfile as
`--build-arg`s. The shared build knobs (`GPU_ARCH`, `CPU_ARCH`,
`ROCM_VERSION`, `ROCM_PATH`, `GCC_VERSION`, `SPACK_BRANCH`,
`SPACK_PACKAGES_TAG`, `BUILD_JOBS`) and the validation disclaimer are in the
[main README](../README.md#build-configuration). Docker-specific knobs:

| Variable | Default |
|---|---|
| `IMAGE_NAME` | `cp2k` |
| `IMAGE_TAG` | `latest` |
| `BASE_IMAGE` | `rocm/dev-ubuntu-24.04:7.2-complete` |

Example: build an MI300X / Zen3 image off a ROCm 7.0 base:

```bash
BASE_IMAGE=rocm/dev-ubuntu-24.04:7.0-complete \
    GPU_ARCH=gfx942 \
    CPU_ARCH=zen3 \
    ROCM_VERSION=7.0.0 \
    IMAGE_TAG=mi300x \
    ./docker/build_cp2k.sh
```

### Manual `docker build`

If you want to skip the wrapper:

```bash
cd /path/to/cp2k-recipe
DOCKER_BUILDKIT=1 docker build \
    -t cp2k:latest \
    -f docker/Dockerfile \
    --build-arg GPU_ARCH=gfx950 \
    --build-arg CPU_ARCH=zen5 \
    --build-arg ROCM_VERSION=7.2.0 \
    .
```

The `.` at the end is critical — the build context must be the repo root
so the `shared/` directory is available to `COPY`.

### Build flags

`build_cp2k.sh` accepts:

- `--clean` — remove old containers / images before building
- `--no-cache` — bypass Docker cache
- `--cache-from IMAGE` — use `IMAGE` as a cache source

> **Disclaimer**: This image has only been validated with the default
> values. Different base images, GPU targets, or ROCm versions may cause
> build failures or suboptimal performance.

## Running the container

The container exposes `cp2k.psmp` on `PATH` and bakes in sane OpenMPI/UCX
runtime defaults (matching the run scripts). It needs the AMD KFD/DRI
devices and `--ipc=host` for GPU IPC.

### Interactive shell

```bash
docker run --rm -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --ipc=host \
    -e PMIX_MCA_gds=^ds21 \
    -v "$PWD":/workdir -w /workdir \
    cp2k:latest /bin/bash
```

### One-off command

```bash
docker run --rm \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    --ipc=host \
    -e PMIX_MCA_gds=^ds21 \
    -v "$PWD":/workdir -w /workdir \
    cp2k:latest \
    bash -c "cp2k.psmp -i input.inp -o output.out"
```

### Singularity / Apptainer

Convert the local Docker image:

```bash
singularity build cp2k.sif docker-daemon://cp2k:latest
singularity shell --no-home --writable-tmpfs cp2k.sif
```

## Running benchmarks

The scripts in [`scripts/`](scripts/) mirror the corresponding files in
[`baremetal/scripts/`](../baremetal/scripts/) — same filenames, same
SBATCH header, same lowercase topology variables, same EXPNAME and output
directory layout. The only difference is that the `mpirun` call is wrapped
in `docker run` against the `cp2k` image. They mount the CP2K source
benchmarks from the host (cloning them on first run if needed) and write
outputs to `docker/outputs/<benchmark>/...`.

| Script | Benchmark |
|---|---|
| `scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run` | `QS_DM_LS / H2O-dft-ls.NREP2` |
| `scripts/cp2k_QS_mp2_rpa_32-H2O.run` | `QS_mp2_rpa / 32-H2O` (init + solver) |

Both scripts double as SLURM batch jobs (just `sbatch` them on a system
that allows running docker inside SLURM) and as plain interactive scripts
(just `./` them) — the SBATCH directives are shell comments when run
outside SLURM, and every `SLURM_*` variable has a sensible default.

The topology variables (`numa_per_node`, `gpus_per_node`, etc.), MPI/UCX
defaults, figure of merit, and the `DBCSR_USE_ACC_G2G` option are shared
across flavors and documented in the
[main README](../README.md#running-cp2k-benchmarks). The docker launchers
add one knob:

| Variable | Default |
|---|---|
| `CONTAINER_IMAGE` | `cp2k:latest` |

Set `numa_per_node` to your node's actual NUMA domain count (`numactl -H`).

Examples:

```bash
# DFT, interactive
./docker/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run

# DFT against a different image, smaller box
CONTAINER_IMAGE=cp2k:mi300x SLURM_NTASKS=8 numa_per_node=4 gpus_per_node=4 \
    ./docker/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run

# RPA, interactive
./docker/scripts/cp2k_QS_mp2_rpa_32-H2O.run

# Either as a SLURM job (set numa_per_node to the node's NUMA count)
sbatch --export=ALL,numa_per_node=<domains> ./docker/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
sbatch --export=ALL,numa_per_node=<domains> ./docker/scripts/cp2k_QS_mp2_rpa_32-H2O.run
```

Output goes under
`docker/outputs/<benchmark>/<experiment>/<arch>_N<nodes>.n<ranks>.t<threads>.g<gpus>_<jobid>/...`
and each script prints the [figure of merit](../README.md#figure-of-merit)
from the resulting `*.out`.

The launchers internally:
1. Clone CP2K source (for benchmark inputs) into `../cp2k_repo/` on first run.
2. Run `docker run` with `--device=/dev/kfd --device=/dev/dri --ipc=host`,
   bind-mounting the benchmark dir at `/benchmark` and the host output
   directory at `/outputs`.
3. Inside the container, source the Spack env, locate `cp2k.psmp` and
   `close.sh`, then call `mpirun --map-by ppr:N:numa:PE=T close.sh cp2k.psmp ...`.

## Runtime options

### GPU-to-GPU communication

The DFT launcher sets `DBCSR_USE_ACC_G2G=1`; it is not set image-wide. See
[GPU-to-GPU communication](../README.md#gpu-to-gpu-communication) in the
main README. To disable it for a comparison run:

```bash
DBCSR_USE_ACC_G2G=0 ./docker/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
```

### MPI / UCX

The image bakes the same OpenMPI/UCX defaults listed in the
[main README](../README.md#mpi--ucx-defaults). Override via `-e VAR=...` on
`docker run`.

## Troubleshooting

### Build fails

1. `cat docker/build.log` for the full Spack output.
2. Make sure the build context is the repo root (`.`), not `docker/` —
   `shared/` must be visible.
3. Verify the base image has the matching ROCm version.
4. Ensure ~50 GB free disk; Spack's build stage is large.

### `cp2k.psmp not found` inside the container

```bash
docker run --rm -it cp2k:latest bash
source /opt/cp2k-build/spack_git/share/spack/setup-env.sh
spack env activate cp2k
spack load cp2k
which cp2k.psmp
```

The image's `PATH` includes `/opt/cp2k/bin`, which symlinks to the Spack
install prefix; this should normally just work.

### GPU not detected

- Verify `/dev/kfd` and `/dev/dri` exist on the host.
- `docker run --rm --device=/dev/kfd --device=/dev/dri cp2k:latest rocm-smi`
- Confirm the `GPU_ARCH` baked into the image matches your hardware
  (`gfx942` for MI300X, `gfx950` for MI350X, etc.).

## Files in this directory

```
docker/
├── Dockerfile          # ROCm base + shared/cp2k_build.sh
├── build_cp2k.sh       # `docker build` wrapper
└── scripts/
    ├── _run_common.sh  # docker run helpers (mirrors baremetal/scripts/_run_common.sh)
    ├── cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
    └── cp2k_QS_mp2_rpa_32-H2O.run
```
