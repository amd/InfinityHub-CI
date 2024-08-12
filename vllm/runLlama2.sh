MY_DATA_FOLDER=$HOME/LLAMA2/data/

# ------------------------------------------------------------------------
# Docker setup
# -----
llama_data_dir=$MY_DATA_FOLDER

container=vllm-rocm

echo "Starting container version " $container

cmd="docker run -it --rm --ipc=host --network=host --privileged --cap-add=CAP_SYS_ADMIN  \
          --device=/dev/kfd --device=/dev/dri --device=/dev/mem \
	  --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined  \
	  -v $llama_data_dir:/data $container /bin/bash"

echo #cmd

$cmd 

exit 0
