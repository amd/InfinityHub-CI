# CP2K — Singularity / Apptainer Build

Same Spack recipe as [`../baremetal/`](../baremetal/) and [`../docker/`](../docker/),
packaged as a Singularity image. Use this on hosts (e.g. HPC/SLURM clusters)
that have Singularity/Apptainer but not Docker.

## Requirements

- Singularity CE / Apptainer (4.x recommended) on `PATH`. On clusters that
  expose it as a module, load it first (e.g. `module load singularity`); the
  run scripts also try `module load ${SINGULARITY_MODULE:-singularity}`
  automatically if `singularity` is not found.
- `--fakeroot` capability for an unprivileged build (subuid/subgid mapping or a
  site fakeroot config). If unavailable, build where you have it and copy the
  `.sif`.
- Git, ~50 GB free disk, internet during the build.

Supported CPUs/GPUs/OS are in the
[main README](../README.md#system-requirements).

## Build

Run from the repo root so `shared/` is in the build context:

```bash
./singularity/build_cp2k.sh
```

Produces `singularity/cp2k.sif`. Defaults: `gfx950` / `zen5` / ROCm `7.2.0`.

The shared build knobs (`GPU_ARCH`, `CPU_ARCH`, `ROCM_VERSION`, `ROCM_PATH`,
`GCC_VERSION`, `SPACK_BRANCH`, `SPACK_PACKAGES_TAG`, `BUILD_JOBS`) and the
validation disclaimer are in the
[main README](../README.md#build-configuration). Singularity-specific knobs:
`BASE_IMAGE` (ROCm base image), `SIF_IMAGE` (output/run image path), and
`FAKEROOT` (set `0` if fakeroot is unavailable). Override via env vars
(forwarded as `--build-arg`):

```bash
GPU_ARCH=gfx942 CPU_ARCH=zen3 ROCM_VERSION=7.0.0 \
    BASE_IMAGE=rocm/dev-ubuntu-24.04:7.0-complete \
    ./singularity/build_cp2k.sh

# If fakeroot is not available:
FAKEROOT=0 ./singularity/build_cp2k.sh
```

## Running benchmarks

Same filenames, SBATCH headers, topology vars, and output layout as
[`../docker/scripts/`](../docker/scripts/); launch via `singularity exec --rocm`.

| Script | Benchmark |
|---|---|
| `scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run` | `QS_DM_LS / H2O-dft-ls.NREP2` |
| `scripts/cp2k_QS_mp2_rpa_32-H2O.run` | `QS_mp2_rpa / 32-H2O` (init + solver) |

Both scripts double as SLURM batch jobs (just `sbatch` them) and as plain
interactive scripts (just `./` them) — the SBATCH directives are shell
comments when run outside SLURM, and every `SLURM_*` variable has a sensible
default. They clone the CP2K source into `../cp2k_repo/` on first run to get
the benchmark inputs.

The topology variables (`numa_per_node`, `gpus_per_node`, etc.), MPI/UCX
defaults, figure of merit, and the `DBCSR_USE_ACC_G2G` option are shared
across flavors and documented in the
[main README](../README.md#running-cp2k-benchmarks). The singularity
launchers add `SIF_IMAGE` (path to the `.sif` to run). Set `numa_per_node`
to your node's actual NUMA domain count (`numactl -H`).

```bash
# Interactive
./singularity/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
./singularity/scripts/cp2k_QS_mp2_rpa_32-H2O.run

# SLURM (set numa_per_node to the node's NUMA count)
sbatch --export=ALL,numa_per_node=<domains> ./singularity/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run

# Override the image or topology via env vars
SIF_IMAGE=/path/to/cp2k.sif SLURM_NTASKS=8 numa_per_node=4 gpus_per_node=4 \
    ./singularity/scripts/cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
```

Outputs go to `singularity/outputs/<benchmark>/...` and each script prints
the [figure of merit](../README.md#figure-of-merit) from the resulting
`*.out`.

## Troubleshooting

- **`singularity: command not found`** — load the module first
  (`module load ${SINGULARITY_MODULE:-singularity}`); the run scripts also
  attempt this automatically.
- **Build fails without fakeroot** — pass `FAKEROOT=0`, or build on a host
  where you have fakeroot and copy the resulting `.sif`.
- **GPU not detected** — ensure `/dev/kfd` and `/dev/dri` exist and that the
  `GPU_ARCH` baked into the image matches your hardware.

## Files in this directory

```
singularity/
├── cp2k.def            # ROCm base + shared/cp2k_build.sh
├── build_cp2k.sh       # `singularity build` wrapper
└── scripts/
    ├── _run_common.sh  # singularity exec helpers (mirrors baremetal/scripts/_run_common.sh)
    ├── cp2k_QS_DM_LS_H2O-dft-ls-NREP2.run
    └── cp2k_QS_mp2_rpa_32-H2O.run
```
