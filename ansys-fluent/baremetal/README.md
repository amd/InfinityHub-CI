# Ansys Fluent Base Container

## Overview
This container recipe is a 'boiler-plate' for those with a license for Ansys Fluent. 
A user must have licenses and binaries to be able to use Ansys Fluent within the container. 

## Ansys Fluent
[Ansys Fluent](https://www.ansys.com/products/fluids/ansys-fluent/) is an advanced computational fluid dynamics (CFD) software used for simulating and analyzing fluid flow, heat transfer, and related phenomena in complex systems. It offers a range of powerful features for detailed and accurate modeling of various physical processes, including turbulence, chemical reactions, and multiphase flows. 


## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Installing Ansys Fluent
This installation guide assumes that you have a license for Ansys Fluent and a tar with the Fluent application provided by Ansys.
This example, is using a tar with the name `fluent.24.2.lnamd64.tgz`.

### Build System Requirements
- ROCm
- Mesa 3D Graphics libraries and XCB Utilities Libraries
- MPI Stack *Optional*
    - OpenMPI/UCC/UCX 
    - Cray MPI

### Install Steps
This example installs Ansys Fluent into /opt, but this is not required.


- Extract tar files

```
cd /opt 
tar -xzvf fluent.24.2.lnamd64.tgz
```
- Adding Fluent to PATH and setting environment variables
```
export PATH=/opt/ansys_inc/v242/fluent/bin:/opt/ansys_inc/v242/fluent/bench/bin:$PATH
export ANSGPU_OVERRIDE=1

```
- Link Fluent Python into Path
```
ln -s /opt/ansys_inc/v242/commonfiles/CPython/3_10/linx64/Release/python/bin/python /usr/bin/python
```
or 
```
sudo update-alternatives -set python /opt/ansys_inc/v242/commonfiles/CPython/3_10/linx64/Release/python/bin/python
```
- Setup external MPI **Optional**  
This example uses local Open MPI installed at `/opt/ompi`. 
To use CRAY MPI, point it to the root of the install. 
```
export OPENMPI_ROOT=/opt/ompi
```

### Ansys License
There are 2 License methods for Ansys Fluent. One of the following is required to Run Ansys Fluent on a node. 
#### License Server
The `ANSYSLMD_LICENSE_FILE` environment variable should be set to the AnsysLMD server address that you use.
`export ANSYSLMD_LICENSE_FILE=1055@localhost`

#### Temporary License 
This example uses a file `ansyslmd.ini` as the licensing file. 
This assumes Fluent is installed in `/opt/ansys_inc/` 
```
cp ./ansyslmd.ini /opt/ansys_inc/shared_files/licensing/
ANSYSLI_ELASTIC=1

# SSL shenanigans (fixes elastic issue)
capath=/etc/ssl/certs
cacert=/etc/ssl/certs/ca-certificates.crt

echo "capath=/etc/ssl/certs" >> $HOME/.curlrc
echo "cacert=/etc/ssl/certs/ca-certificates.crt" >> $HOME/.curlrc

cd /etc/ssl/certs && wget http://curl.haxx.se/ca/cacert.pem && ln -s cacert.pem ca-bundle.crt
```

## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|Ansys Fluent|Custom|[Ansys Fluent](https://www.ansys.com/products/fluids/ansys-fluent)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
