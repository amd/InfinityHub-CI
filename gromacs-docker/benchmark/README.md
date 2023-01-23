To run benchmark simply type:

./run_benchmark.sh -t mode

where mode can be either "mpi" or "tmpi"

To get finer grained performance, consider the following modifications to the scripts:

1. Set -nstlist to a number somewhere between 100-400.
2. Assigned multiple MPI threads per GPU.

For single node runs, it is recommended to use the tmpi option. The mpi option is untested

More tips and advice on performance tuning:
https://developer.nvidia.com/blog/creating-faster-molecular-dynamics-simulations-with-gromacs-2020/
https://manual.gromacs.org/current/user-guide/mdrun-performance.html#running-mdrun-within-a-single-node

