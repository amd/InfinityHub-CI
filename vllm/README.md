# Docker Build for LLAMA2

This document is intended to help the reader build a Dockerfile for performance testing of the LLAMA2 application. This docker file uses a base install that includes Ubuntu 20.04, ROCm 6.1.2 and Python 3.9.

Please refer to https://docs.vllm.ai/en/latest/getting_started/amd-installation.html for additional details or installation options. For example, the link contains instructions to install vLLM v0.5.3.

The container can host the LLAMA2 application (Large Language Model) and requires some large input files for testing. The input files are in the 150 – 200 GB file size and are not included in the container.

The Dockerfile is found in github repo shown below. A variation of the Dockerfile, based on ROCm 6.1.1, is included as a sample file in the current repo.

To create the Docker container, download the VLLM files:

```git clone  https://github.com/ROCm/vllm.git  --branch main --recurse-submodules vllm```

You should now have a vllm directory that contains the Dockerfile, the vllm files.

There are a few updates that are required to have a successful run. Please find and update the following files within the Dockerfile image.

1.  vllm/engine/arg_utils.py
  
    gpu_memory_utilization: float = 0.9

2.  gradlib/testing/config.json

    "max_position_embeddings": 32768,

3.  If there is a config.json file in the data input directory and max_position_embeddings is a parameter, set the value to 32768

     "max_position_embeddings": 32768,

The Dockerfile that comes with the vllm code is for an install using Cuda. There is also a Dockerfile.rocm for ROCm. We are going to use the Dockerfile.rocm file. 

Build the Docker container for ROCm using:

```docker build -t vllm-rocm -f Dockerfile.rocm . ```

The tag (-t <tag>) can be your choice but must match the tag used to start the Docker container in any other script.

Create a script to run the container. You need to have the input files available in a host directory. The example below assumes that files are store in $HOME/data and that the container tag is vllm-rocm:


```console
MY_DATA_FOLDER=$HOME/data/
#------------------------------------------------------------------------
#Docker setup
#------------------------------------------------------------------------

llama_data_dir=$MY_DATA_FOLDER
container=vllm-rocm
echo "Starting container version " $container

cmd="docker run -it --rm --ipc=host --network=host --privileged --cap-add=CAP_SYS_ADMIN \
   --device=/dev/kfd --device=/dev/dri --device=/dev/mem \
   --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
   -v $llama_data_dir:/data $container /bin/bash"

echo $cmd

$cmd
```

Start the container using your custom script.

In the /app/vllm directory, there are files to run the example code. Edit or run the benchmark_latency.sh or benchmark_throughput.sh scripts as appropriate. Verify the following:

1.  --model should point to the directory containing the desired input LLM files.
2.  -tp should be coded according to the number of GPUs to use for a run. For a single run, with one GPU code -tp 1.
3.  --output-len is the number of characters to generate for a test run. This is also known as the output length. Performance is very dependent on the amount of output that is generated.
4.  --input-len is the number of characters to used as the input length for a test run. One could code any number from 1 to the max input len for the specific LLM (e.g. 1024 or 2048).
5.  --num-iters is the number of iterations for a test run. This should be a reasonable small number (say 3 to 10).

Run the tests and collect output. Collect the output for post processing:

./benchmark_latency.sh -tp 4 --num-iters 10 | tee output.file

A simple grep command will provide the essential output: grep “Avg\|RUN” output.file



## Licensing Information
Your access and use of this application is subject to the terms of the applicable component-level license identified below. To the extent any subcomponent in this container requires an offer for corresponding source code, AMD hereby makes such an offer for corresponding source code form, which will be made available upon request. By accessing and using this application, you are agreeing to fully comply with the terms of this license. If you do not agree to the terms of this license, do not access or use this application.

The application is provided in a container image format that includes the following separate and independent components:
|Package | License | URL|
|---|---|---|
|Ubuntu| Creative Commons CC-BY-SA Version 3.0 UK License |[Ubuntu Legal](https://ubuntu.com/legal)|
|ROCm|Custom/MIT/Apache V2.0/UIUC OSL|[ROCm Licensing Terms](https://rocm.docs.amd.com/en/latest/about/license.html)|
|PyTorch|BSD-3|[PyTorch License](https://github.com/pytorch/pytorch?tab=License-1-ov-file#readme)|
|Flash Attention|BSD-3-Clause|[Flash Attention License](https://github.com/ROCm/flash-attention?tab=BSD-3-Clause-1-ov-file#readme)|
|CuPy |MIT|[CuPy License](https://github.com/ROCm/cupy?tab=MIT-1-ov-file#readme)|
|Triton |MIT|[Triton License](https://github.com/triton-lang/triton?tab=MIT-1-ov-file#readme)|
|vLLM |Apache-2|[vLLM License](https://github.com/ROCm/vllm#Apache-2.0-1-ov-file)|

Additional third-party content in this container may be subject to additional licenses and restrictions. The components are licensed to you directly by the party that owns the content pursuant to the license terms included with such content and is not licensed to you by AMD. ALL THIRD-PARTY CONTENT IS MADE AVAILABLE BY AMD “AS IS” WITHOUT A WARRANTY OF ANY KIND. USE OF SUCH THIRD-PARTY CONTENT IS DONE AT YOUR SOLE DISCRETION AND UNDER NO CIRCUMSTANCES WILL AMD BE LIABLE TO YOU FOR ANY THIRD-PARTY CONTENT. YOU ASSUME ALL RISK AND ARE SOLELY RESPONSIBLE FOR ANY DAMAGES THAT MAY ARISE FROM YOUR USE OF THIRD-PARTY CONTENT.

## Disclaimer
The information contained herein is for informational purposes only, and is subject to change without notice. In addition, any stated support is planned and is also subject to change. While every precaution has been taken in the preparation of this document, it may contain technical inaccuracies, omissions and typographical errors, and AMD is under no obligation to update or otherwise correct this information. Advanced Micro Devices, Inc. makes no representations or warranties with respect to the accuracy or completeness of the contents of this document, and assumes no liability of any kind, including the implied warranties of noninfringement, merchantability or fitness for particular purposes, with respect to the operation or use of AMD hardware, software or other products described herein. No license, including implied or arising by estoppel, to any intellectual property rights is granted by this document. Terms and limitations applicable to the purchase or use of AMD’s products are as set forth in a signed agreement between the parties or in AMD's Standard Terms and Conditions of Sale.

## Notices and Attribution
© 2022-2024 Advanced Micro Devices, Inc. All rights reserved. AMD, the AMD Arrow logo, Instinct, Radeon Instinct, ROCm, and combinations thereof are trademarks of Advanced Micro Devices, Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries. Docker, Inc. and other parties may also have trademark rights in other terms used herein. Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

All other trademarks and copyrights are property of their respective owners and are only mentioned for informative purposes.
