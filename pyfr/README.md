# PyFR

## Overview
PyFR is an open-source Python based framework for solving advection-diffusion type problems on streaming architectures using the Flux Reconstruction approach of Huynh. The framework is designed to solve a range of governing systems on mixed unstructured grids containing various element types. Support for AMD hardware has been integrated into the PyFR project and can be found at [PyFR.org](https://www.pyfr.org/) and [PyFR GitHub](https://github.com/PyFR/PyFR).

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Building Recipes
[Docker/Singularity Build](/pyfr/docker/)


## Running PyFR Benchmarks
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.


### PyFR Examples
There are several PyFR examples in the [PyFR Test Cases](https://github.com/PyFR/PyFR-Test-Cases.git) repo as well as a [Naca0021](/pyfr/docker/examples/naca0021/) and [TVG](/pyfr/docker/examples/tgv/) that PyFR supports. We have details for the latter. 
> Note:
> These benchmarks/examples prefer to be run in an interactive session, if the output is captured to a file, it will result in a single line with possibly hundreds of thousands of characters. `tail -c 80 <PyFR-example.log>` should capture the last executed frame with the elapsed time. Depending on the size of the example, it may be a few characters off. 

<details>
<summary> TGV </summary>  

#### TGV
The script converts the mesh to a PyFR mesh first and compiles the GPU kernels, and executes the simulation.  
As a convenience, this is performed in the benchmark script which can be run using 1 or 2 GPUs.  
Replace `<NGPU>` with the desired number of GPUs to use
```
/examples/tgv/run_tgv <NGPU>
```
</details>

<details>
<summary>  NACA0021 </summary>

#### NACA0021
The script extracts, then converts the mesh to a PyFR mesh first, for multiple GPU runs it will partition the mesh, then compiles the GPU kernels, and executes the simulation.  
As a convenience, this is performed in the benchmark script which can be run using 1 to 8 GPUs.  
Replace `<NGPU>` with the desired number of GPUs to use
```
/examples/naca0021/run_naca0021 <NGPU>
```
</details>

<details>
<summary>  PyFR Test Cases </summary>

#### PyFR Test Cases
The PyFR test cases have been already provided into the container, they are located at `/examples/PyFR-Test-Cases`, These examples must be run interactively. 
The instructions on how to run these test cases can be located at [PyFr Examples](https://pyfr.readthedocs.io/en/latest/examples.html).
> NOTES:
> - The examples use `cuda` be sure to replace this with `hip` to run with AMD GPUs.  
> - Paraview has not been included in the container  
> - Unstructured VTK (.vtu) files can be placed in a mounted directory to access them on host machine. See [Docker](https://docs.docker.com/storage/volumes/) or [Singularity](https://apptainer.org/user-docs/master/bind_paths_and_mounts.html) documentation for details on how to mount a directory into the container. 

</details>

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|CMAKE|OSI-approved BSD-3 clause|[CMake License](https://cmake.org/licensing/)|
|OpenMPI|BSD 3-Clause|[OpenMPI License](https://www-lb.open-mpi.org/community/license.php)<br /> [OpenMPI Dependencies Licenses](https://docs.open-mpi.org/en/v5.0.x/license/index.html)|
|OpenUCX|BSD 3-Clause|[OpenUCX License](https://openucx.org/license/)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|PyFR|BSD-3 Clause|[PyFR](https://www.pyfr.org/)<br /> [PyFR License](https://github.com/PyFR/PyFR/blob/develop/LICENSE)|
|PyFR Test Cases|Creative Commons Attribution 4.0|[PyFR Test Cases License](https://github.com/PyFR/PyFR-Test-Cases)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
