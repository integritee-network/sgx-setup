#!/bin/bash

set -ex

sudo systemctl stop aesmd.service
sudo systemctl start aesmd.service

# change permission to be able to build the Sample as normal user
sudo chmod -R 0777 /opt/intel/sgxsdk/SampleCode/SampleEnclave

source environment
cd SampleCode/SampleEnclave
make clean
SGX_MODE=SIM make

echo " " | ./app
