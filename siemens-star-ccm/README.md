# Siemens Star CCM+

## Siemens Star CCM+
[Siemens Star CCM+](https://plm.sw.siemens.com/en-US/simcenter/fluids-thermal-simulation/star-ccm/)  is a comprehensive computational fluid dynamics (CFD) and multiphysics simulation software developed by Siemens Digital Industries Software. It is designed to help engineers and researchers analyze and optimize the performance of products and systems across various industries.


## Single-Node Server Requirements
[System Requirements](/README.md#single-node-server-requirements) 

## Star Build/Install options
- [Baremetal](/siemens-star-ccm/baremetal/)
- [Dockerfile](/siemens-star-ccm/docker/)  

## Siemens License
There are a couple of licensing methods to use StarCCM+. Find details on your license within your [Siemens Support Center](https://support.sw.siemens.com/en-US) account.

## Running StarCCM+
The following is an example of how to run StarCCM+. 
> **NOTES:**
> - Make sure to include `-cpubind gpgpuawre`. 
> - Replace `<NGPU>` with the number of GPUs to use for the problem. Using insufficient GPUs for the problem size will cause unexpected exits.   
> - This example using `OpenMPI` to use other replace `openmpi` with the mpi implementation of your cluster. 
> - This example is running a benchmark, with 40 pre-iterations (`-preits`) and 20 iterations (`-nits`).
> - Be sure to replace the `<example.sim>` with the input file to be tested. 

```
starccm+ -mpi openmpi -np <NGPU> -cpubind gpgpuaware -gpgpu auto:<NGPU>  -benchmark "-preits 40 -nits 20  -nps <NGPU>"  <example.sim>
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
