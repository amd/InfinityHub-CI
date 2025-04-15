#!/bin/bash
#
# Script is expected to be in, and executed from, the root directory
# of the HPC_Benchmark directory
source ${OPENFOAM_DIR}/etc/bashrc
cd ${0%/*} || exit 1    # Run from this directory
CDIR=`pwd`
# set the benchmark case
benchmark_case=incompressible/icoFoam/cavity3D/8M/fixedIter

function setup()
{
    # setting the env
    MAXGPUS=10
    if [[ ${NGPUS} -le 0 ]] ||  [[ ${NGPUS} -gt ${MAXGPUS} ]]; then  
        # ERR condition
        echo " ERROR: This script is designed to run with a maximum of ${MAXGPUS} GPUs."
        echo "        Either change your current selection of NGPUs: ${NGPUS} or modify the 'MAXGPUS' count in the script!  "
        exit 1
    fi
    gpu_string="0"
    for (( gpunum=1; gpunum<${NGPUS} ; gpunum++ )) ; do
        gpu_string+=",${gpunum}"
    done
    export HIP_VISIBLE_DEVICES=${gpu_string}

    # set PETSC_OPTIONS
    export PETSC_OPTIONS='-use_gpu_aware_mpi 0'
    
    # Source tutorial run functions
    . $WM_PROJECT_DIR/bin/tools/RunFunctions

    # Lets run the 3D Lid-driven cavity benchmark (M) case using the folloring commands:
    cd HPC_Benchmark/${benchmark_case}
    if [ ! -x Allrun ] && [ ! -x Allclean ]
    then
        chmod +x All*
    fi
    app=`getApplication`
}

function generateMesh()
{
    # 1. blockMesh | This is used to create the 3D block mesh for the CFD test
    echo "--------------------
    Stage #1
--------------------"

    if [[ $RUN_ONLY -eq 0 ]]; then
        echo "Running blockMesh. Check progress in the log file using command
        tail -f log.blockMesh"
        blockMesh &> $OUTPUT/log.blockMesh
        # 2. renumberMesh -overwrite | This is used to re-order and overwrite the mesh point and neighbor lists that reduces the matrix band.
        renumberMesh -overwrite &> $OUTPUT/log.renumberMesh
    else
        if [ -d "./constant/polyMesh" ]
        then
            echo " Skipping blockMesh (mesh generation) and moving to next stage"
        else
            echo "
Error: no constant/polyMesh exists in HPC_Benchmark/${benchmark_case}.
       Remove -r flag and re-run this script to generate the mesh with blockMesh."
            exit 1
       fi
    fi

}

function singleGPUrun()
{
    if [[ $VERBOSE -eq 1 ]]; then
        ${app} 2>&1 | tee $OUTPUT/log.${app}-${NGPUS}gpu
    else
        #3. icoFoam  | This is the solver that that is used in this benchmark.
        ${app} &> $OUTPUT/log.${app}-${NGPUS}gpu
    fi
    #4. foamLog | This extracts the relevant KPIs (e.g. Execution time, residuals, etc.)
    foamLog $OUTPUT/log.${app}-${NGPUS}gpu
}


function parallelGPUrun()
{
    if [[ $VERBOSE -eq 1 ]]; then
      sed -i -e "s|.*numberOfSubdomains.*|numberOfSubdomains ${NGPUS};|g" ./system/decomposeParDict
      decomposePar -force 2>&1 | tee $OUTPUT/log.decomposePar-${NGPUS}gpu
      mpirun -np ${NGPUS} ${app} -parallel 2>&1 | tee $OUTPUT/log.${app}-${NGPUS}gpu
    else
      #3. decomposePar | This is used to decompose the 3D mesh into subdomains for parallel processing
      sed -i -e "s|.*numberOfSubdomains.*|numberOfSubdomains ${NGPUS};|g" ./system/decomposeParDict
      decomposePar -force &> $OUTPUT/log.decomposePar-${NGPUS}gpu
      #
      #4. icoFoam  | This is the solver that that is used in this benchmark.
      mpirun -np ${NGPUS} ${app} -parallel &> $OUTPUT/log.${app}-${NGPUS}gpu
      #
      #5. foamLog | This extracts the relevant KPIs (e.g. Execution time, residuals, etc.)
    fi
    foamLog $OUTPUT/log.${app}-${NGPUS}gpu
}

function printFOM()
{
    echo "--------------------
    Final results:
--------------------"
    if [[ $NGPUS -eq 1 ]]; then
        awk 'NR>=270 && NR<=284' $OUTPUT/log.${app}-${NGPUS}gpu
    else
        awk 'NR>=279 && NR<=294' $OUTPUT/log.${app}-${NGPUS}gpu
    fi
    echo "--------------------
    FOM: Execution Time
    Extracting the FOM from the final results

Time   ExecutionTime (s)
-------------------"
    cat logs/executionTime_0 | awk 'END{print}'
    echo "--------------------"
}

function clean()
{
    # Source tutorial run functions
    . $WM_PROJECT_DIR/bin/tools/RunFunctions

    # Lets run the 3D Lid-driven cavity benchmark (M) case using the folloring commands:
    cd HPC_Benchmark/${benchmark_case}
    if [ ! -x Allrun ] && [ ! -x Allclean ]
    then
        chmod +x All*
    fi
    ./Allclean
}

function usage()
{
    echo "

This script is designed to setup and run OpenFOAM ${benchmark_case} benchmark on GPUs.
=================================
usage: $0

       -h | --help      Prints the usage
       -g | --ngpus     #GPUs to be used (between 1-10), defaults to 1
       -r | --run-only  skip mesh build, and directly run the case
       -c | --clean     Clean the case directory
       -v | --verbose   Prints all logs from different stages for easy debugging
       -o | --output    Change the output directory to a different directory


"
}

parse_args(){
    set +u
    while (( "$#" )); do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -g|--ngpus)
                NGPUS="$2"
                shift 2
                ;;
            -c|--clean)
                clean
                exit 1
                ;;
            -r|--run-only)
                RUN_ONLY=1
                shift 1
                ;;
            -v|--verbose)
                VERBOSE=1
                shift 1
                ;;
            -o|--output)
                OUTPUT="$(realpath $2)"
                shift 2
                ;;
            -*|--*=|*) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                usage
                exit 1
                ;;
        esac
    done

    if [[ -z "${NGPUS+x}" ]]; then
        NGPUS=1
        echo "Using default $NGPUS GPU for this benchmark"
    fi

    if [[ -z "${RUN_ONLY+x}" ]]; then
        RUN_ONLY=0
    fi

    if [[ -z "${VERBOSE+x}" ]]; then
        VERBOSE=0
    fi
    if [[ -z "${OUTPUT+x}" ]]; then
        OUTPUT=.
    fi
}

#*******************************************************
#
# This is the Main part of this bash script which calls
# the functions above based on user choices
#
#*******************************************************


parse_args $*
setup
generateMesh

if [[ ${NGPUS} -eq 1 ]]
then
    echo "--------------------
    Stage #2
--------------------
    Running the benchmark with single GPU"
    singleGPUrun
elif [[ ${NGPUS} -gt 1 ]]
then
    echo "--------------------
    Stage #2
--------------------
    Running the benchmark with multiple (${NGPUS}) GPUs"
    parallelGPUrun
else
    echo "Error : nGPUS is not >1"
fi

printFOM

#EOF
