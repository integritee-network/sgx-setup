#!/bin/bash
set -ex

# download and execute the script to install the desired llvm version
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh ${LLVM_VERSION}