#!/bin/bash

source /opt/spack/share/spack/setup-env.sh

spack env activate /opt/cp2k_environment
spack external find --all
spack concretize -f
spack install -j16

ln -s `spack find -p cp2k@2026.1 | tail -n 1 | awk 'BEGIN{FS=" "} {print $2}'` /opt/cp2k

