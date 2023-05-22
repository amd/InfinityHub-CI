#!/bin/bash

##############################################
# Script that just assigns GPUs/GCDs to ranks
#
# Relies on environment variables to be set
# for cases other than default
##############################################

if [[ -n ${OMPI_COMM_WORLD_RANK+z} ]]; then
  # ompi
  export global_rank=${OMPI_COMM_WORLD_RANK}
  export local_rank=${OMPI_COMM_WORLD_LOCAL_RANK}
  export ranks_per_node=${OMPI_COMM_WORLD_LOCAL_SIZE}
elif [[ -n ${MV2_COMM_WORLD_RANK+z} ]]; then
  # mvapich2
  export global_rank=${MV2_COMM_WORLD_RANK}
  export local_rank=${MV2_COMM_WORLD_LOCAL_RANK}
  export ranks_per_node=${MV2_COMM_WORLD_LOCAL_SIZE}
elif [[ -n ${SLURM_LOCALID+z} ]]; then
    # mpich via srun
    export global_rank=${SLURM_PROCID}
    export local_rank=${SLURM_LOCALID}
    export ranks_per_node=$(($SLURM_NTASKS/$SLURM_NNODES))
fi

# Set defaults
let NUM_CPUS=${NUM_CPUS:-128}
let RANK_STRIDE=${RANK_STRIDE:-${NUM_CPUS}/${ranks_per_node}}
let OMP_STRIDE=${OMP_STRIDE:-1}
let NUM_GPUS=${NUM_GPUS:-8}
let GPU_START=${GPU_START:-0}
let GPU_STRIDE=${GPU_STRIDE:-1}

let ranks_per_gpu=$(((${ranks_per_node}+${NUM_GPUS}-1)/${NUM_GPUS}))
let my_gpu=$(($local_rank*$GPU_STRIDE/$ranks_per_gpu))+${GPU_START}

arch=${GPU_ARCH_INP}
export HIP_VISIBLE_DEVICES=$my_gpu
echo "rank_local= " $local_rank "  HIP_VISIBLE_DEVICES= " $HIP_VISIBLE_DEVICES

"$@"

