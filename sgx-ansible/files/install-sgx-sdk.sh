#!/bin/bash
exec_file=$(find . -type f -name sgx_linux_x64_sdk_*.bin -printf "%f\n" )
chmod +x $exec_file
debug_out=$(expect -c "
spawn sudo ./$exec_file
expect \" :\"
send \"yes\r\";
interact;
expect \" :\"
send \"yes\r\";
interact;
")
