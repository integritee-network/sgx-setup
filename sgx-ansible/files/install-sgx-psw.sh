#!/bin/bash
linux_distro_name="$1"
sdk_version="$2"
set -ex

apt="${sdk_version}-${linux_distro_name}1"

# make intel-sgx repo available in apt
echo "deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu ${linux_distro_name} main" | sudo tee /etc/apt/sources.list.d/intel-sgx.list
wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | sudo apt-key add -

sudo apt update
# make sure we deinstall all sgx packages
expect -c "
spawn sudo apt remove libsgx-launch libsgx-urts libsgx-epid libsgx-urts libsgx-quote-ex libsgx-aesm-quote-ex-plugin libsgx-aesm-epid-plugin libsgx-uae-service sgx-aesm-service
expect \" :\"
send \"Y\r\";
interact  "
expect -c "
spawn sudo apt autoremove
expect \" :\"
send \"Y\r\";
interact  "
# reinstall for current sdk build version
expect -c "
spawn sudo apt install libsgx-launch libsgx-urts libsgx-epid libsgx-urts libsgx-quote-ex libsgx-aesm-quote-ex-plugin libsgx-aesm-epid-plugin
libsgx-uae-service sgx-aesm-service
expect \" :\"
send \"Y\r\";
interact  "
