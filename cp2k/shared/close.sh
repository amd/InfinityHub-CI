#!/bin/bash
#
# Bind one MPI rank to one GPU using ROCR_VISIBLE_DEVICES.
#
# Wrap a CP2K (or other) command with this script after mpirun, e.g.:
#   mpirun -np N --map-by ppr:K:numa:PE=T close.sh cp2k.psmp -i in.inp
#
# Works with OpenMPI (OMPI_COMM_WORLD_*) and falls back to MPICH-style
# MPI_LOCALNRANKS / MPI_LOCALRANKID variables.

if [ -n "${OMPI_COMM_WORLD_SIZE:-}" ]; then
    mpi_size=${OMPI_COMM_WORLD_SIZE}
    mpi_rank=${OMPI_COMM_WORLD_RANK}
    mpi_node_size=${OMPI_COMM_WORLD_LOCAL_SIZE}
    mpi_node_rank=${OMPI_COMM_WORLD_LOCAL_RANK}
else
    mpi_size=-1
    mpi_rank=-1
    mpi_node_size=${MPI_LOCALNRANKS:-1}
    mpi_node_rank=${MPI_LOCALRANKID:-0}
fi

gpus_per_node=${GPUS_PER_NODE:-8}
gpus_per_rank=$(( gpus_per_node / mpi_node_size ))
if [ "${gpus_per_node}" -le "${mpi_node_size}" ]; then
    ranks_per_gpu=$(( mpi_node_size / gpus_per_node ))
else
    ranks_per_gpu=1
fi
devid=$(( mpi_node_rank / ranks_per_gpu ))

ROCR_VISIBLE_DEVICES=${devid}
export ROCR_VISIBLE_DEVICES

echo "host=$(hostname -s) ngpus=${gpus_per_node} nprocs=${mpi_size} rank=${mpi_rank} nprocs_local=${mpi_node_size} rank_local=${mpi_node_rank} ROCR_VISIBLE_DEVICES=${ROCR_VISIBLE_DEVICES}"

exec "$@"
