#!/bin/bash
linux_distro_name="$1"
set -ex

# build the psw installers
source linux/installer/bin/sgxsdk/environment
sudo make deb_psw_pkg

# make them available in apt
sudo make deb_local_repo
sudo echo "deb [trusted=yes arch=amd64] file:${PWD}/linux/installer/deb/sgx_debian_local_repo ${linux_distro_name} main" | sudo tee /etc/apt/sources.list.d/intel-libsgx.list

sudo apt update

# install
sudo apt install libsgx-epid libsgx-urts libsgx-uae-service -y
