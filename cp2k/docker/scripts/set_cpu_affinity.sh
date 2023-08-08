#!/bin/bash

if [[ -n ${OMPI_COMM_WORLD_RANK+x} ]]; then
  # ompi
  export global_rank=${OMPI_COMM_WORLD_RANK}
  export local_rank=${OMPI_COMM_WORLD_LOCAL_RANK}
  export ranks_per_node=${OMPI_COMM_WORLD_LOCAL_SIZE}
elif [[ -n ${MV2_COMM_WORLD_RANK+x} ]]; then
  # mvapich2
  export global_rank=${MV2_COMM_WORLD_RANK}
  export local_rank=${MV2_COMM_WORLD_LOCAL_RANK}
  export ranks_per_node=${MV2_COMM_WORLD_LOCAL_SIZE}
elif [[ -n ${SLURM_LOCALID+x} ]]; then
    # mpi via srun
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
if [[ -z ${GPU+x} ]]; then
    let GPU="MI210"
fi

# Optimal ordering of CPU cores w.r.t. GPU devices is different for MI250X
# Need GPU and NUM_CPUS to be set to MI250X and 64 respectively
if [[ $GPU == "MI250X"  && $NUM_CPUS == "64" ]]; then
    cpu_list=(48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47)
else
    cpu_list=($(seq 0 127))
fi

let cpus_per_gpu=${NUM_CPUS}/${NUM_GPUS}
let cpu_start_index=$(( ($RANK_STRIDE*${local_rank})+${GPU_START}*$cpus_per_gpu ))
let cpu_start=${cpu_list[$cpu_start_index]}
let cpu_stop=$(($cpu_start+$OMP_NUM_THREADS*$OMP_STRIDE-1))

export GOMP_CPU_AFFINITY=$cpu_start-$cpu_stop:$OMP_STRIDE
echo "rank_local= " $local_rank "  GOMP_CPU_AFFINITY= " $GOMP_CPU_AFFINITY

"$@"
