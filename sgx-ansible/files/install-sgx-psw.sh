#!/bin/bash
linux_distro_name="$1"
set -ex

# Build the psw installers.
source linux/installer/bin/sgxsdk/environment
sudo make deb_psw_pkg

# Make them available in apt.
sudo make deb_local_repo
sudo echo "deb [trusted=yes arch=amd64] file:${PWD}/linux/installer/deb/sgx_debian_local_repo ${linux_distro_name} main" | sudo tee /etc/apt/sources.list.d/intel-libsgx.list

sudo apt update
# Remove installed packages to ensure clean installation process.
sudo apt remove libsgx-epid libsgx-urts libsgx-uae-service libsgx-launch libsgx-urts libsgx-epid libsgx-urts libsgx-quote-ex libsgx-aesm-quote-ex-plugin libsgx-aesm-epid-plugin sgx-aesm-service -y
sudo apt autoremove -y
# Reinstall on clean state.
sudo apt install libsgx-epid libsgx-urts libsgx-uae-service libsgx-launch libsgx-urts libsgx-epid libsgx-urts libsgx-quote-ex libsgx-aesm-quote-ex-plugin libsgx-aesm-epid-plugin sgx-aesm-service -y
