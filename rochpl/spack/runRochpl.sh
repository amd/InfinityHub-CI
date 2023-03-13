echo "Note: edit this file to run either MI100 or MI250 tests"

source  $HOME/spack/share/spack/setup-env.sh
pushd `spack location --install-dir rochpl`
pwd

echo "To run rochpl for MI210 1,2,4,8 GPU:"
echo ./mpirun_rochpl -P 1 -Q 1 -N 90112  --NB 512
echo ./mpirun_rochpl -P 2 -Q 1 -N 128000 --NB 512
echo ./mpirun_rochpl -P 2 -Q 2 -N 180224 --NB 512
echo ./mpirun_rochpl -P 2 -Q 4 -N 180224 --NB 512

echo "To run rochpl for MI100 1,2,4,8 GPU:"
echo ./mpirun_rochpl -P 1 -Q 1 -N 64000 --NB 512
echo ./mpirun_rochpl -P 1 -Q 2 -N 90112 --NB 512
echo ./mpirun_rochpl -P 2 -Q 2 -N 126976 --NB 512
echo ./mpirun_rochpl -P 2 -Q 4 -N 180224 --NB 512

popd
