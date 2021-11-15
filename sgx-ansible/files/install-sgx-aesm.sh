#!/bin/bash
linux_distro_name="$1"
set -ex

# make intel-sgx repo available in apt
echo "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu ${linux_distro_name} main" | sudo tee /etc/apt/sources.list.d/intel-sgx.list
wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | sudo apt-key add -
sudo apt-get update
expect -c "
spawn sudo apt-get install libsgx-launch libsgx-urts libsgx-epid libsgx-urts libsgx-quote-ex  libsgx-aesm-quote-ex-plugin libsgx-aesm-epid-plugin
expect \" :\"
send \"Y\r\";
interact  "
