#!/bin/bash

echo "running AMD SPECFEM3D Benchmark: `date`"
currentdir=`pwd`

if [ -z "$1" ]; then NPROC="1"; else NPROC="$1"; fi

echo "sets up directory structure in current example directory"
echo
echo "   setting up example..."
echo

rm -fr OUTPUT_FILES
rm -fr DATABASES_MPI
rm -fr DATA

mkdir -p OUTPUT_FILES
mkdir -p DATABASES_MPI


# get the number of processors, ignoring comments in the Par_file
cp -r /opt/specfem3d/benchmarks/DATA .
cp DATA/Par_file-$NPROC-proc DATA/Par_file
cp DATA/meshfem3D_files/Mesh_Par_file-$NPROC-proc_288x256 DATA/meshfem3D_files/Mesh_Par_file

echo "The simulation will run on NPROC = " $NPROC " MPI tasks"

# decomposes mesh using the pre-saved mesh files in MESH-default
echo
echo "[1/3]  decomposing mesh..."
echo
mpirun -np $NPROC xmeshfem3D

# runs database generation
echo
echo "[2/3]  running database generation on $NPROC processors..."
echo
mpirun -np $NPROC xgenerate_databases

# runs simulation
echo
echo "[3/3]  running solver on $NPROC processors..."
echo
mpirun -np $NPROC --report-bindings xspecfem3D

echo
if [ ! -z "$2" ]; then 
    cp -a OUTPUT_FILES/. $2/
    echo "see results in directory: $2";
else 
    echo "see results in directory: OUTPUT_FILES/"
fi

echo
echo "done"
echo `date`