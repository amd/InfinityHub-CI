# Amber

## Overview
Amber is a suite of biomolecular simulation programs. It began in the late 1970's, and is maintained by an active development community.
 - [Amber History](https://ambermd.org/History.php) 
 - [Amber Contributors](https://ambermd.org/contributors.html)

The term **Amber** refers to two things:
1. A set of molecular mechanical [force fields](https://ambermd.org/AmberModels.php) for the simulation of biomolecules (these force fields are in the public domain, and are used in a variety of simulation programs). 
2. A package of [molecular simulation programs](https://ambermd.org/AmberTools.php) which includes source code and demos.

The updated AMD/HIP support in Amber22 can be downloaded from [The Amber Project](https://ambermd.org/GPUSupport.php). To download the source code for Amber visit [The Amber Projects Download page](https://ambermd.org/GetAmber.php). 

Amber is actively developed with collaboration from:
 - David Case at Rutgers University
 - Tom Cheatham at the University of Utah
 - Ken Merz at Michigan State University 
 - Adrian Roitberg at the University of Florida
 - Carlos Simmerling at SUNY-Stony Brook
 - Scott LeGrand at NVIDIA 
 - Darrin York at Rutgers University
 - Ray Luo at UC Irvine
 - Junmei Wang at the University of Pittsburgh
 - Maria Nagan at Stony Brook
 - Ross Walker at GSK
 - Many more... 
 
 Amber was originally developed under the leadership of Peter Kollman.

Conflex has created an [Introduction to Amber](http://www.conflex.co.jp/prod_amber.html). (in Japanese)

## Single-Node Server Requirements

| CPUs | GPUs | Operating Systems | ROCm™ Driver | 
| ---- | ---- | ----------------- | ------------ | 
| X86_64 CPU(s) | AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s) <br> Radeon Instinct MI50(S)| Ubuntu 18.04 <BR> CentOS 8.3 | ROCm v4.x compatibility |

For ROCm installation procedures and validation checks, see:
* [ROCm Documentation](https://rocm.docs.amd.com)
* [AMD Lab Notes ROCm installation notes](https://github.com/amd/amd-lab-notes/tree/release/rocm-installation).
* [ROCm Examples](https://github.com/amd/rocm-examples)


## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

Amber is licensed and distributed by the University of California.  AMD optimizations to the Amber code have been provided by AMD to the University of California and are incorporated into the Amber 22 codebase. 


The application requires the following separate and independent components:
|Package | License | URL|
|---|---|---|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/release/licensing.html)|
|Amber|Custom|[Amber](https://ambermd.org/)<br >[Amber License](https://ambermd.org/GetAmber.php)|



Additional the components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2023 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
