# Cadence Fidelity LES Solver

## Overview
Fidelity LES Solver, formally Cadence CharLES, is a part of the Cadence Computational Fluid Dynamics Platform.
Fidelity LES is the industry’s first high-fidelity computational fluid dynamics (CFD) solver that expands the practical application of large eddy simulations (LES) to a broad range of engineering applications. Designed to tackle the toughest fluid dynamics challenges, it accurately predicts traditionally complex problems for CFD in aeroacoustics, aerodynamics, combustion, heat transfer, and multiphase. Fidelity LES software introduces a paradigm shift to the industry with the ability to leverage both computer processing units (CPUs) and graphical processing units (GPUs), reducing the turnaround time for LES simulations from days to hours. The solver has been optimized to consume as little memory as possible and scales linearly to hundreds of GPUs across dozens of nodes.  
Find more information about below:  
- [Cadence Computational Fluid Dynamics](https://www.cadence.com/en_US/home/tools/system-analysis/computational-fluid-dynamics/fidelity.html)  
- [Fidelity LES Solver](https://www.cadence.com/en_US/home/tools/system-analysis/computational-fluid-dynamics/fidelity.html#fidelity-charles)


## Single-Node Server Requirements
| CPUs | GPUs | Operating Systems | ROCm™ Driver | 
|---- |---- |----------------- |------------ |
| X86_64 CPU(s) |[ AMD Instinct MI200 GPU(s) <br>  AMD Instinct MI100 GPU(s)](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html#supported-gpus) | Ubuntu <br> RHEL <br>  SLES | [ROCm 5.x ](https://rocm.docs.amd.com/en/latest/release/versions.html) 


## Licensing Information
Your use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/release/licensing.html)|
|Cadence Computational Fluid Dynamics|Custom/Contact for License Details |[Cadence](https://www.cadence.com)<br>[Request Cadence CFD License](https://www5.cadence.com/CFD_ReqTrial_LP.html)|


Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL LINKED THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF THE CONTAINER IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THE CONTAINER.
 
## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

 
## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
