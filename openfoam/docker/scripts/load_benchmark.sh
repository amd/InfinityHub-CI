#!/bin/bash
source ${OPENFOAM_DIR}/etc/bashrc
CDIR=`pwd`
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"


usage(){
  echo \
"""
Usage:
$0 [[OPTIONS]]

Options
-------------
[--prefix] Base installation directory

"""
}


parse_args(){
    set +u
    while (( "$#" )); do
        case "$1" in
            --prefix)
                PREFIX="$(realpath $2)"
                shift 2
                ;;
            -*|--*=|*) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                usage
                exit 1
                ;;
        esac
    done

    if [[ -z "${PREFIX+x}" ]]; then
        PREFIX="$CDIR"
    else
        mkdir -p ${PREFIX}
    fi
}

function configure_lidCavity()
{
    # configure and setup Lid_driven cavity
    cp -r ${SDIR}/data/Lid_driven_cavity/fvSolution HPC_Benchmark/incompressible/icoFoam/cavity3D/8M/fixedIter/system/.
    sed -i -e "s|\/\/libs|libs|g" ${PREFIX}/HPC_Benchmark/incompressible/icoFoam/cavity3D/8M/fixedIter/system/controlDict
    sed -i -e "s|endTime         0.5;|endTime         0.005;|g" ${PREFIX}/HPC_Benchmark/incompressible/icoFoam/cavity3D/8M/fixedIter/system/controlDict
}

function configure_hpcMotorbike()
{
    # configure and setup HPC_motorbike
    mv HPC_Benchmark/incompressible/simpleFoam/HPC_motorbike/Small/v1912/system/fvSolution HPC_Benchmark/incompressible/simpleFoam/HPC_motorbike/Small/v1912/system/fvSolution.cpu
    cp -r ${SDIR}/data/HPC_Motorbike/fvSolution HPC_Benchmark/incompressible/simpleFoam/HPC_motorbike/Small/v1912/system/.
    sed -i '16 i libs  (petscFoam);' ${PREFIX}/HPC_Benchmark/incompressible/simpleFoam/HPC_motorbike/Small/v1912/system/controlDict
    sed -i -e "s|endTime         500;|endTime         20;|g" ${PREFIX}/HPC_Benchmark/incompressible/simpleFoam/HPC_motorbike/Small/v1912/system/controlDict
}

function load_benchmark()
{
    cd $PREFIX
    git clone https://develop.openfoam.com/committees/hpc.git HPC_Benchmark
    configure_lidCavity
    configure_hpcMotorbike
    echo "
     ---------------------------------------------------------------------
     The medium 3D lid-driven cavity benchmark with 200^3 cells and the 
     small HPC_motorbike case with ~8 Million cells, are configured in:
     ${PREFIX}.
     ---------------------------------------------------------------------

Please source the openfoam environment, e.g.: source <your-path-to>/OpenFOAM-v2106/etc/bashrc.
Also please verify that the PETSc libraries can be loaded properly. Run the following commands:
     eval \$(foamEtcFile -sh -config petsc -- -force)
     foamHasLibrary -verbose petscFoam

Then go the the benchmark tests at the location described above and run the respective scripts:
1. bench-lid-driven-cavity  | This is used to run the 3D Lid-driven cavity benchmark
2. bench-hpc-motorbike      | This is used to run the HPC-motirbike benchmark"
}


parse_args $*
load_benchmark
