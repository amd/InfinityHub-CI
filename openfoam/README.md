# OpenFOAM with PETSc Solver

OpenFOAM is the free, open source computational fluid dynamics (CFD) software developed primarily by OpenCFD Ltd since 2004. It has a large user base across most areas of engineering and science, from both commercial and academic organizations. OpenFOAM has an extensive range of features to solve anything from complex fluid flows involving chemical reactions, turbulence and heat transfer, to acoustics, solid mechanics and electro-magnetics.

OpenFOAM is professionally released every six months to include customer sponsored developments and contributions from the community. It is independently tested by ESI-OpenCFD's Application Specialists, Development Partners and selected customers, and supported by ESI's worldwide infrastructure, values and commitment.

Quality assurance is based on rigorous testing. The process of code evaluation, verification and validation includes several hundred daily unit tests, a medium-sized test battery run on a weekly basis, and large industry-based test battery run prior to new version releases. Tests are designed to assess regression behavior, memory usage, code performance and scalability

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Building Recipes
[Docker/Singularity Build](/openfoam/docker/)

## Running OpenFOAM
This section describes how to launch two HPC Benchmarks approved by the [OpenFOAM HPC Technical Committee](https://wiki.openfoam.com/High_Performance_Computing\_(HPC)\_Technical\_Committee). For the container there are [OpenFoam Benchmark Scripts](/openfoam/docker/scripts/) that have been included at `/benchmark` inside the container that allow running the `Lid_driven_cavity-3D` and `HPC_motorbike` benchmarks, respectively. If OpenFOAM has been installed with ROCm and MPI support, similarly to the [OpenFOAM container](/openfoam/docker/Dockerfile) these [OpenFoam Benchmark Scripts](/openfoam/docker/scripts/) will work in any environment. 
> NOTE:  
> All benchmarks available from the [OpenFOAM HPC Technical Committee](https://develop.openfoam.com/committees/hpc) are available in the [OpenFOAM Docker Image](/openfoam/docker/Dockerfile) in the `/benchmark/HPC_Benchmark` directory and can be run by following the instructions provided in the repository. Follow a similar procedure for your customized workloads/benchmarks to use PETSc solvers and enable GPU offloading.


### Run OpenFOAM Benchmarks
There are a few options that can be applied to both benchmarks. 

```
-h | --help      Prints the usage
-g | --ngpus     #GPUs to be used (between 1-10), defaults to 1
-r | --run-only  skip mesh build, and directly run the case
-c | --clean     Clean the case directory
-v | --verbose   Prints all logs from different stages for easy debugging
```

HPC Motorbike benchmark:
```
./bench-hpc-motorbike.sh -g 8 -v
```
LID Driven Cavity 3D benchmark:
```
./bench-lid-driven-cavity.sh -g 8 -v
```


> NOTE:
> * If the `-g` is not mentioned in commands above, by default the script will use 1 GPU. But for consistency, we recommend always adding the `-g` to prescribe #GPUs.
> * The number of GPUs can be altered to run on multiple GPUs. When #GPUs>1, the number of MPI ranks used will be equal to the number of GPUs. For example, when launched with 4 GPUs, 4 MPI ranks will be deployed. The script will automatically  adjust the MPI ranks to the number of GPUs.
> * It must be noted that the script is designed to run on a maximum of 10 GPUs at a time, and will require alteration if #GPUs>10 need to be used. One can also assign multiple-MPI ranks to each GPU, however that is not included in these bash scripts.
> * When a benchmark is run using the script above, the mesh for the case is generated in `Stage #1`. Generally this stage can take some time (~10-30mins depending on the benchmark). To re-run the benchmark with a different set of #GPU count, one can skip the pre-processing and setup `Stage #1` by passing the `-r` argument to the bash script. For example, let's consider that `Lid_driven_cavity-3D` benchmark was initially run with 1 GPU. To re-run the same benchmark with 4 GPUs, one can use the following command to skip `Stage #1` and save time on setup  
>``` 
> ./bench-lid-driven-cavity.sh -g 4 -r -v
>```
> * The `-v` enables verbose output that prints more details for the benchmark as it runs for several time steps. 

At the end of the run, the benchmark script prints the final results on the terminal and extracts the figure-of-merit (FOM) for reference. An example of the final result from the `Lid_driven_cavity-3D` with 8 GPUs benchmark is:
```
--------------------
    Final results:
--------------------
PETSc-cg:  Solving for p, Initial residual = 0.188515, Final residual = 7.52086e-05, No Iterations 11
time step continuity errors : sum local = 3.17586e-09, global = -9.83611e-22, cumulative = -1.89179e-20
ExecutionTime = 73.29 s  ClockTime = 71 s

Time = 0.00475

Courant Number mean: 0.0594596 max: 0.486125
PETSc-bcgs:  Solving for Ux, Initial residual = 0, Final residual = 5.98599e-05, No Iterations 5
PETSc-bcgs:  Solving for Uy, Initial residual = 0, Final residual = 0.000125888, No Iterations 5
PETSc-bcgs:  Solving for Uz, Initial residual = 0, Final residual = 0.00137425, No Iterations 5
PETSc-cg:  Solving for p, Initial residual = 0.191332, Final residual = 6.81069e-05, No Iterations 11
time step continuity errors : sum local = 2.86518e-09, global = -2.08493e-22, cumulative = -1.91264e-20
PETSc-cg:  Solving for p, Initial residual = 0.16702, Final residual = 6.39609e-05, No Iterations 11
time step continuity errors : sum local = 2.69255e-09, global = -2.06132e-21, cumulative = -2.11878e-20
ExecutionTime = 76.9 s  ClockTime = 74 s

--------------------
    FOM: Execution Time
    Extracting the FOM from the final results

Time   ExecutionTime (s)
-------------------
0.005   80.52
--------------------
```

## Licensing Information

Your use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|OpenFOAM|GPL v3|[OpenFOAM](https://www.openfoam.com)<br />[OpenFOAM License](https://www.openfoam.com/documentation/licencing)|
|PETSc|BSD-2 Clause | [PETSc](https://petsc.org/)<br />[PETSc License](https://petsc.org/release/install/license/)|
|PETScFOAM|GPL V3|[PETSc4FOAM](https://develop.openfoam.com/modules/external-solver)|
|HYPRE|Apache V2.0/MIT|[HYPRE Licenses](https://github.com/hypre-space/hypre#license)|
|Scotch|CeCILL-C|[Scotch Web Page](https://www.labri.fr/perso/pelegrin/scotch/)<br /> [Scotch License](https://gitlab.inria.fr/scotch/scotch/-/blob/master/LICENSE_en.txt)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.

See the [OpenFOAM official page](https://www.openfoam.com/documentation/licencing) for more information on licensing.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
