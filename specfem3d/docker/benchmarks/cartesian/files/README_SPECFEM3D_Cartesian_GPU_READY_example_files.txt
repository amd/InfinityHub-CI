
The contents of this archive contains files from the example under specfem3d/EXAMPLES/meshfem3D_examples/simple_model and also includes some variations of the Par_file and Mesh_Par_file used by that example. The modified files allow for running on 1,2,or 4 GPUs or running on CPU only. There are 2 sets of files to accomodate comparing either 32 core CPU or 36 core CPU. For the 32 core CPU the mesh size is 256x256. For the 36 core CPU file set the mesh size is 288x256. That difference simply allows all the CPU cores to be use for either the 32 core or 36 core cases. There are additional details in the Par_file and Mesh_par_file comments.

Also included running script examples for both the 32 and 36 core CPU cases. From reviewing the files it should be possible to create additional variation if the user desires for 28 core or 40 core or other cases as needed.



File list :
************

DATA/CMTSOLUTION
DATA/FORCESOLUTION
DATA/Par_file-1-proc					# variations of Par_file and Mesh_Par_file from simple_model example
DATA/Par_file-2-proc
DATA/Par_file-32-proc_CPU
DATA/Par_file-36-proc_CPU
DATA/Par_file-4-proc
DATA/STATIONS
DATA/STATIONS_FILTERED

DATA/meshfem3D_files/
DATA/meshfem3D_files/interface1.dat
DATA/meshfem3D_files/interface2.dat
DATA/meshfem3D_files/interfaces.dat
DATA/meshfem3D_files/Mesh_Par_file-1-proc_256x256
DATA/meshfem3D_files/Mesh_Par_file-1-proc_288x256
DATA/meshfem3D_files/Mesh_Par_file-2-proc_256x256
DATA/meshfem3D_files/Mesh_Par_file-2-proc_288x256
DATA/meshfem3D_files/Mesh_Par_file-32-proc_CPU_256x256
DATA/meshfem3D_files/Mesh_Par_file-36-proc_CPU_288x256
DATA/meshfem3D_files/Mesh_Par_file-4-proc_256x256
DATA/meshfem3D_files/Mesh_Par_file-4-proc_288x256


README_GPU_READY_example_files.txt

run_1_2_4_gpu_and_cpu_only_32_or_36_cores.sh  	# example running script



The lines below are excerpt from the Par_File in the simple_model example to highlight variations in the test case
*********************************************************************************************************

# number of MPI processors
NPROC                           = 4     # modified for 1,2,4,GPU or 32 or 36 CPU core cases

# time step parameters
NSTEP                           = 10000		# increased problem size
DT                              = 0.01



GPU_MODE                        = .true.	# adjust true or false depending whether running GPUs or CPU only


The lines below are excerpt from the DATA/meshfem3D_files/Mesh_Par_File in the simple_model example to highlight variations in the test cases used for 1,2,4 GPU and 32 or 36 CPU core test cases
***********************************************************************************************************

# number of elements at the surface along edges of the mesh at the surface
# (must be 8 * multiple of NPROC below if mesh is not regular and contains mesh doublings)
# (must be multiple of NPROC below if mesh is regular)
NEX_XI                          = 288		# this adjusts the mesh size (ie 256x256 for 32 core CPU)
NEX_ETA                         = 256

# number of MPI processors along xi and eta (can be different)
NPROC_XI                        = 2		# needs to multiply to be the number of NPROC
NPROC_ETA                       = 2



# first 3 regions below need to be modified to match the mesh size above

# number of regions
NREGIONS                        = 4
# define the different regions of the model as :
#NEX_XI_BEGIN  #NEX_XI_END  #NEX_ETA_BEGIN  #NEX_ETA_END  #NZ_BEGIN #NZ_END  #material_id
1              288            1               256             1         4        1
1              288            1               256             5         5        2
1              288            1               256             6         15       3
14             25            7               19             7         10       4




