#!/bin/bash

export HIP_VISIBLE_DEVICES=$OMPI_COMM_WORLD_LOCAL_RANK

case $OMPI_COMM_WORLD_LOCAL_RANK in
        [0]) cpus=0-15 ;;
        [1]) cpus=16-31;;
        [2]) cpus=32-47;;
        [3]) cpus=48-63;;
        [4]) cpus=64-79;;
        [5]) cpus=80-95;;
        [6]) cpus=96-111;;
        [7]) cpus=112-127;;
esac

numactl $@
