import os
import sys
import glob
import shutil
import pathlib
import argparse
import subprocess


__dirname = os.path.dirname(os.path.realpath(__file__))
__datapath = os.path.join(__dirname, 'files')


def input_files_gpu(gpu_count, mesh_size):
    '''Return Par and Mesh input files for running benchmarks on GPU

    Does not validate input

    Args:
        gpu_count (int): number of gpus to use
        mesh_size (str): mesh dimension to use

    '''
    par_file = os.path.join(
        __datapath,
        'DATA/Par_file-{}-proc'.format(gpu_count))
    mesh_path = 'DATA/meshfem3D_files/'
    mesh_file = os.path.join(
        __datapath,
        mesh_path,
        'Mesh_Par_file-{}-proc_{}'.format(gpu_count, mesh_size))
    return par_file, mesh_file


def input_files_cpu(cpu_count):
    if cpu_count == 32:
        mesh_size = '256x256'
    elif cpu_count == 36:
        mesh_size = '288x256'
    else:
        return None, None

    par_file = os.path.join(
        __datapath,
        'DATA/Par_file_{}_proc_CPU'.format(cpu_count)
    )

    mesh_path = 'DATA/meshfem3D_files'
    mesh_file = os.path.join(
        __datapath,
        mesh_path,
        'Mesh_Par_file_{}_proc_CPU_{}'.format(cpu_count, mesh_size)
    )
    return par_file, mesh_file


def input_files(cpu_count, gpu_count, mesh_size):
    '''Return appropriate Par and Mesh file for the benchmark

    Args:
        cpu_count (int): number of cores to use
        gpu_count (int): number of GPUs to use
        mesh_size (str): 2D mesh dimension
    Returns:
        (str, str): Path to 'Par' and 'Mesh' files. If not found,
        returns None

    '''
    if gpu_count != 0:
        return input_files_gpu(gpu_count, mesh_size)
    return input_files_cpu(cpu_count)


def _is_in_path(name):
    '''Returns if given executable name is in path

    Args:
        name (str): name of the executable

    Returns:
        (bool): True if in path, False otherwise

    '''

    for path in os.environ['PATH'].split(os.pathsep):
        fpath = os.path.join(path, name)
        if os.path.isfile(fpath) and os.access(fpath, os.X_OK):
            return True
    return False


def bin_path(name):
    if _is_in_path(name):
        return name
    return os.path.join(__dirname, '../../', 'bin', name)


def _expand_args(args_str):
    arg_list = args_str.split(' ')
    return [arg.strip() for arg in arg_list if arg.strip() != '']


def run_case(cpu_count, gpu_count, mesh_size, mpi_args, outpath):
    par_file, mesh_file = input_files(cpu_count, gpu_count, mesh_size)

    tmp_outdir = os.path.join(__datapath, 'OUTPUT_FILES')
    dbdir = os.path.join(__datapath, 'DATABASES_MPI')
    pathlib.Path(tmp_outdir).mkdir(parents=True, exist_ok=True)
    pathlib.Path(dbdir).mkdir(parents=True, exist_ok=True)

    if not mesh_file or not par_file:
        print('Cannot find compatible input files', file=sys.stderr)
        return

    # Preprocess
    shutil.copyfile(par_file, os.path.join(__datapath, 'DATA/Par_file'))
    shutil.copyfile(
        mesh_file, os.path.join(__datapath, 'DATA/meshfem3D_files/Mesh_Par_file'))

    if cpu_count > 0:
        proc_count = cpu_count
    else:
        proc_count = gpu_count

    # Run
    helper = os.path.join(__datapath, 'helper.sh')

    print('[1/3] Generating mesh')
    subprocess.check_call(
        ['mpirun', '-np', str(proc_count), bin_path('xmeshfem3D')],
        cwd=__datapath)

    print('[2/3] Generating databases')
    subprocess.check_call(
        ['mpirun', '-np', str(proc_count), bin_path('xgenerate_databases')],
        cwd=__datapath)

    cmd_args = ['mpirun', '-np', str(proc_count)] \
        + _expand_args(mpi_args) \
        + [helper, bin_path('xspecfem3D')]

    print('[3/3] Running solver')
    env = os.environ.copy()
    env.update({'ROC_ACTIVE_WAIT': '1'})
    subprocess.check_call(cmd_args, cwd=__datapath, env=env)

    # Post run
    suffix = '_c{}_g{}_s{}'.format(cpu_count, gpu_count, mesh_size)
    out_abs = os.path.abspath(outpath + suffix)
    pathlib.Path(out_abs).mkdir(parents=True, exist_ok=True)
    for fname in glob.glob(os.path.join(__datapath, 'OUTPUT_FILES/*.txt')):
        shutil.copy(fname, out_abs)


def create_parser(parser):
    parser.add_argument(
        '-g', '--gpu-count',
        nargs='+',
        type=int,
        required=True,
        choices=[
            0, 1, 2, 4, 8
        ],
        help='Number of gpus')

    parser.add_argument(
        '-c', '--cpu-count',
        type=int,
        required=False,
        choices=[0, 32, 64],
        help='Number of cores to use')

    # 256x256 mesh sizes are currently not compatible
    parser.add_argument(
        '-s', '--size',
        type=str,
        required=True,
        choices=['288x256'],
        help='Mesh size')

    parser.add_argument(
        '--mpi-args',
        type=str,
        required=False,
        default='',
        help='Additional MPI arguments used when running solver')

    parser.add_argument(
        '-o', '--output-path',
        type=str,
        required=False,
        default='out',
        help='Output path. Directory will be suffixed by cpu and gpu counts')
    return parser


def run(parser_args):
    args = parser_args
    for gpu_count in args.gpu_count:
        run_case(
            args.cpu_count,
            gpu_count,
            args.size,
            args.mpi_args,
            args.output_path
        )


def main():
    parser = argparse.ArgumentParser(
        description='Cartesian benchmark problem executor')
    parser = create_parser(parser)
    args = parser.parse_args()
    run(args)


if __name__ == '__main__':
    main()
