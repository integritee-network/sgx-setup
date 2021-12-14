#!/bin/bash
driver_version="$1"

chmod +x sgx_linux_x64_driver_$driver_version.bin
sudo ./sgx_linux_x64_driver_$driver_version.bin
