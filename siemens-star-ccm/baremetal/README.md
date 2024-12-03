# Siemens Star CCM+

## Overview
This container recipe is a 'boiler-plate' for those with a license for Siemens Star CCM+. 
A user must have licenses and binaries to be able to use Siemens Star CCM+. 

## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

### Build System Requirements
- ROCm
- For MPI implementations other than OpenMPI
    - Cray MPI
    - HPE MPI

## Installing Siemens StarCCM+
This installation guide assumes that you have a license for Siemens for StarCCM+ application. 
License and binaries can be found at the [Siemens Support Center](https://support.sw.siemens.com/en-US)
This example is using a zip file named `STAR-CCM+19.04.009_01_linux-x86_64-2.28_clang17.0.zip`

### Siemens License
There are a couple of licensing methods to use StarCCM+. Find details on your license within your [Siemens Support Center](https://support.sw.siemens.com/en-US) account.


### Install Steps
This example installs Siemens Star CCM+ into /opt, but this is not required. 

- Download zip file from [Siemens Support Center](https://support.sw.siemens.com/en-US).
Find the correct version for your license and system.  
Do not download the tarball with 'gnu' in the name; this legacy build does not support AMD GPUs.  

- Extract zip file
```
unzip STAR-CCM+19.04.009_01_linux-x86_64-2.28_clang17.0.zip
```

- Run installation script. 
Running the following will install Siemens Star CCM+.
There are a couple of prompts, if you wish to install using default settings, add `-i silent` as an input to the `sh` file. 

```
cd STAR-CCM+19.04.009_01_linux-x86_64-2.28_clang17.0 
./STAR-CCM+19.04.009_01_linux-x86_64-2.28_clang17.0.sh
```

**OPTIONAL** Setup Environment Variables   
- Add StarCCM+ to system `PATH`
```
export PATH=$PATH:/opt/Siemens/19.04.009/STAR-CCM+19.04.009/star/bin
```

Find your license details before configuring the following. 
- Configure the license server
```
export CDLMD_LICENSE_FILE=1999@<server-address>
```
- Configure Power on Demand License  
If you are using a Power on Demand license, it can be helpful to configure this in the environment directly. 

```
export LM_PROJECT=<ABC123456789>
```

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
