# Docker Build for LLAMA2

This document is intended to help the reader build a Dockerfile for performance testing of LLAMA2 application. This docker file uses a base install that includes Ubuntu 20.04, ROCm 6.1.2 and Python 3.9.

Please refer to https://docs.vllm.ai/en/latest/getting_started/amd-installation.html for additional details or installation options. For example, the link contains instructions to install vLLM v0.5.3.

The container can host the LLAMA2 application (Large Language Model) and requires some large input files for testing. The input files are in the 150 – 200 GB file size and are not included in the container.

The Dockerfile, used in the current build, is shown in Appendix A.

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
