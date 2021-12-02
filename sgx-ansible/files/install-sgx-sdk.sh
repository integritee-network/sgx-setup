#!/bin/bash
linux_distro="$1"

# download the prebuilt binaries
sudo make preparation

sudo cp external/toolset/$linux_distro/{as,ld,ld.gold,objdump} /usr/local/bin

# build the installer
sudo make sdk_install_pkg

# install the sdk
cd linux/installer/bin
exec_file=$(find . -type f -name sgx_linux_x64_sdk_*.bin -printf "%f\n" )
debug_out=$(expect -c "
spawn sudo ./$exec_file
expect \" :\"
send \"yes\r\";
interact;
")


# clean up afterwards
cd /usr/local/bin
sudo rm -r {as,ld,ld.gold,objdump}
