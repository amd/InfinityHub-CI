# Siemens Star CCM+ Base Container

## Overview
This container recipe is a 'boiler-plate' for those with a license for Siemens Star CCM+. 
A user must have licenses and binaries to be able to use Siemens Star CCM+ within the container. 
> **NOTE**
> Using a Containerized version of Star CCM+ is not officially supported by Siemens.


## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Docker Container Build
These instructions use Docker to create a container for Siemens Star CCM+.
This container assumes that you have a license for Siemens Star CCM+ and a tarball with the Star CCM+ application provided by Siemens.
These files are expected to be in a directory named `sources` in the docker build context.  
This example, is using a tarball with the name `STAR-CCM+19.04.009_01_linux-x86_64-2.28_clang17.0.zip`.  
Do not download the tarball with 'gnu' in the name; this legacy build does not support AMD GPUs.  

If you are not familiar with creating Docker builds, please see the available [Docker manuals and references](https://docs.docker.com/).

## Build System Requirements
- Git
- Docker

## Updating the Dockerfile

### Input values
Within the dockerfile the default value for the Star CCM+ zip can be hard coded before building or input at build time.  
[Build Details](#building-container) can be found below.  

### Siemens License
There are a couple of licensing methods to use StarCCM+. Find details on your license within your [Siemens Support Center](https://support.sw.siemens.com/en-US) account.



## Inputs
Possible `build-arg` for the Docker build command  
- ### UBUNTU_VERSION
    Default: `jammy`  
    Docker Tags found: 
    - [Docker Ubuntu](https://hub.docker.com/_/ubuntu)
    > jammy is currently recommended as many apps require newer versions of GNU tools than can be installed with `apt-get`. 
- ### STAR_CCM_BINARY_ZIP
    Default: `STAR-CCM+19.04.009_01_linux-x86_64-2.28_clang17.0`
    > **NOTE:**
    > Leave off the `.zip` as this is used to extract and install Star CCM+
- ### STAR_CCM_VERSION
    Default: `19.04.009`
    > **NOTE:**  
    > This value is the numeric value after `STAR-CCM+` in the Binary ZIP name. 
    > This value is used to add StarCCM binaries to the container path. 
- ### CDLMD_LICENSE_FILE  
    - Address of the Siemens License server to acquire a license from.  
    - Formated like: `1999@<server-address>`
- ### LM_PROJECT
    - Power on Demand license obtained from Siemens Portal. 

> **Note**
> All of the License Options: `CDLMD_LICENSE_FILE` and `LM_PROJECT` can be set at run time using environment variables or when running Star CCM+ from a terminal.  
> Providing these values when creating a docker image will build them in. 
> Please find more documentation on setting up Licensing at [Siemens Support Center](https://support.sw.siemens.com/en-US).



## Building Container
Download the [Dockerfile](/siemens-star-ccm/Dockerfile)  

To run the default configuration:
```
docker build -t starccm:latest --build-arg CDLMD_LICENSE_FILE=1999@Localhost -f /path/to/Dockerfile . 
```
> Notes:  
>- `starccm:latest` is an example container name.
>- the `.` at the end of the build line is important. It tells Docker where your build context is located, the Siemens Star CCM+ files should be relative to this path. 
>- `-f /path/to/Dockerfile` is only required if your docker file is in a different directory than your build context. If you are building in the same directory it is not required. 

To run a custom configuration, include one or more customized build-arg parameters.   
*DISCLAIMER:* This Docker build has only been validated using the default values. Alterations may lead to failed builds if instructions are not followed.

```
docker build \
    -t Star CCM+:latest \
    -f /path/to/Dockerfile \
    --build-arg IMAGE=rocm_gpu:6.1.1 \
    --build-arg STAR_CCM_BINARY_ZIP="STAR-CCM+19.04.009_01_linux-aarch64-2.28_gnu11.4" \
    --build-arg CDLMD_LICENSE_FILE=1999@127.0.0.1 \
    --build-arg LM_PROJECT=123456789abc \
    . 
```

## Running an Application Container:
This section describes how to launch the containers. It is assumed that up-to-versions of Docker and/or Singularity is installed on your system.
If needed, please consult with your system administrator or view official documentation.

### Docker  
To run the container interactively, run the following command:
```
docker run -it \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt \
    seccomp=unconfined \
    -v /PATH/TO/TEST_FILES/:/benchmark \
    starccm:latest bash
```

> ** Notes **
> User running container user must have permissions to `/dev/kfd` and `/dev/dri`. This can be achieved by being a member of `video` and/or `render` group.  
> Additional Parameters
> - `-v [system-directory]:[container-directory]` will mount a directory into the container at run time.
> - To use HPE MPI or Cray MPI these Libraries/Binaries must be mounted into the container at run time. Find details for any additional configuration at the [Siemens Support Center](https://support.sw.siemens.com/en-US).
> - `-w [container-directory]` will designate what directory within a container to start in. 
> - `-e [ENV=Value]` will add an environment variable at runtime for a container, can be used to set or overwrite the license server or PoD key. 


### Singularity  
Singularity, like Docker, can be used for running HPC containers.  
To create a Singularity container from your local Docker container, run the following command:
```
singularity build starccm.sif  docker-daemon://starccm:latest
```

Singularity can be used similar to Docker to launch interactive and non-interactive containers, as shown in the following example of launching a interactive run
```
singularity shell --writable-tmpfs starccm.sif
```
> - `--writable-tmpfs` allows for the file system to be writable, many benchmarks/workloads require this.  
> - `--no-home` will *not* mount the users home directory into the container at run time. 
> - `--bind [system-directory]:[container-directory]` will mount a directory into the container  at run time. 
> - To use HPE MPI or Cray MPI these Libraries/Binaries must be mounted into the container at run time. Find details for any additional configuration at the [Siemens Support Center](https://support.sw.siemens.com/en-US).
> - `--pwd [container-directory]` will designate what directory within a container to start in. 
> - `--env [ENV=Value]` will add an environment variable at runtime for a container, can be used to set or overwrite the license server or PoD key. 



*For more details on Singularity please see their [User Guide](https://docs.sylabs.io/guides/3.7/user-guide/)*


## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|Siemens Star CCM+|Custom|[Siemens Star CCM+](https://plm.sw.siemens.com/en-US/simcenter/fluids-thermal-simulation/star-ccm/)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
