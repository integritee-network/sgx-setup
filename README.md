
# Step by Step (Development Server)

There are two different `ansible.yml` files:
1. [BuildServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/BuildServersSGX.yml) : used for continuous build servers, not for active developing. Hence no user and other roles included.
2. [DevelopmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml) : used for development server that support muliple accounts.

In this tutorial, the development server is focused on. The following roles are executed:
- `role-install-tools`: Installs a basic toolbox necessary to install sgxsdk and driver. The tools that will be installed can be checked out [here](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/roles/role-install-tools/tasks/main.yml).
- `role-andrewrothstein.gcc-toolbox`: Installs gcc, necessary to install sgxsdk and driver.
- `role-intel-sgx`: For more information take a look at its dedicated [README](https://github.com/integritee-network/sgx-setup/tree/main/sgx-ansible/roles/role-intel-sgx)
- `role-singleplatform-eng.users`: Needed to set up user accounts. Not necessary to actually run a sgx-machine but is recommended in case of multiple users accessing the same machine.

The other roles (such as the munin-node, timezone and keyboard roles) are not yet tested for ubunutu 20.04 and might be outdated. They will most likely be updated at a later point of time. If urgently needed, take a look at https://github.com/geerlingguy , up-to-date ansible scripts should be found there.

## Requirements
* Ansible v2.8 is required on your HOST (provisioner) system.
* You must have `sshpass` installed on your HOST (provisioner) not on the GUEST (machine(s) being provisioned).
* The GUEST machine must be on Ubuntu 20.04 or 18.04
* SGX must be enabled in the BIOS of your GUEST machine

Clarification of GUEST and HOST: The guest is the machine you want to install intel sgx sdk on. The host is the machine you're using to connect to the guest machine.

### Before starting
* Check if your GUEST machine processor supports FLC (don't know about that? check out this [section](https://github.com/integritee-network/sgx-setup#check-for-flc-support)). If it does not, update the driver version accordingly: https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/group_vars/developmentServersSGX.yml#L46-L54
* This script was tested on Ubuntu 20.04 but it should also support different Ubuntu versions. In case it does not work, please contact us.

## Steps

1. Add your server credentials as a file to the [sgx-setup/sgx-ansible/host_vars/](https://github.com/integritee-network/sgx-setup/tree/main/sgx-ansible/host_vars). An example host can be found in [sgx-ansible/host_vars/examplehost.domain-ad.example.ch.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/host_vars/examplehost.domain-ad.example.ch.yml). Set the `ansible_user` and `ansible_host` according to your sgx-server name:
    ```yml
    ansible_user: examplehost
    ansible_host: examplehost.domain-ad.example.ch
    ```
    Ignore the netplan, munin-node, pkcs12 and nginx information for now. This will only become important when actually setting up these tools, which is not yet supported in this tutorial.

    After adding the file, you also need to add it to [sgxhosts](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/sgxhosts) as a development or build server. Depending on where you add it to, the `BuildServersSGX.yml` or `DevelopmentServersSGX.yml` file will be executed for your server.

2. Install the basic tools on your host system by running the ansible install-tools :
    1. Activate the [role-install-tools](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L19) in [DevelopmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml)
    2. Execute the script according to [Ansible Script Execution](https://github.com/integritee-network/sgx-setup#ansible-script-execution).
3. Install gcc-tools by activating the [role-andrewrothstein.gcc-toolbox](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L20) (don't forget to recomment previously executed roles) and execute it, just like before.
4. Finally activate the [role-intel-sgx](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L22) and execute it as well. This might take some time (30 minutes on fast machines). In case the smoke tests have passed: Congratulation: You have successfully set up an sgx machine :)
 In case they did not, but the script executed without any errors, take a look at section [Check if sgx is enabled in BIOS](https://github.com/integritee-network/sgx-setup/tree/main#check-if-sgx-is-enabled). If that is not the error, create an [issue](https://github.com/integritee-network/sgx-setup/issues/new) so we can try to help you out.
5. Setting up Users:
    1. Save the public key of the user in [sgx-setup/sgx-ansible/files/users/keys](https://github.com/integritee-network/sgx-setup/tree/main/sgx-ansible/files/users/keys), just like the  [example.users.pub](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/files/users/keys/example.user.pub)
    2. Note down the user in the [sgx-ansible/group_vars/developmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/group_vars/developmentServersSGX.yml), just like it has been done for the Example User.
    3. Activate the role in [role-singleplatform-eng.users](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L18) and execute it.


## Ansible Script Execution

To start the playbook, simply execute:
```bash
ansible-playbook site.yml -i sgxhosts -k
```
The option `-k` is used to ask for the connection (SSH) password. This will execute all activated roles in [DevelopmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml) and [BuildServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/BuildServersSGX.yml).

To update specific hosts only, use the following command (adapt `examplehost*` according to your host name):
```bash
ansible-playbook site.yml -i sgxhosts -l "examplehost*" -k
```
### List affected hosts and dry-run
To show which host will be provisioned, execute the upper command with the option `--list-hosts`.

To do a dry-run, execute the upper command with the options `--check --diff`.

## Check if SGX is enabled
Smoke Tests are failing even though sgx driver and sdk have been successfully installed? Then maybe sgx is not enabled in the BIOS.
To check this you can do the following (credit for this how-to goes to http://xiangyi.pro/2020/enable-software-controled-sgx-in-ubuntu/):

Execute the intel linux-sgx `sgx_capable` script by running:
```bash
cd /opt/intel/linux-sgx_{intel_sgx_SDK_PWD_version}/sdk/libcapable/linux/
sudo make
```
where `{intel_sgx_SDK_PWD_version}` is the version number you chose in the [group_vars/developmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/group_vars/developmentServersSGX.yml) file.

Example:
`cd /opt/intel/linux-sgx_2.15.1/sdk/libcapable/linux/`

Then, in the same folder, create a file named `enable_sw_sgx.cpp` with the following content:
```cpp
#include <stdio.h>
#include "../../../common/inc/sgx_capable.h"

int main()
{
   int is_sgx_capable = 0;
   sgx_device_status_t status;

   sgx_is_capable(&is_sgx_capable);
   printf("is_sgx_capable: %d\n", is_sgx_capable);

   sgx_cap_enable_device(&status);
   printf("status: %d\n", (int)status);

   return 0;
}
```
The functions `sgx_is_capable` and `sgx_cap_enable_device` are declared in `linux-sgx_{intel_sgx_SDK_PWD_version}/common/inc/sgx_capable.h` and implemented in `linux-sgx_{intel_sgx_SDK_PWD_version}/sdk/libcapable/linux/` (https://github.com/intel/linux-sgx/blob/master/common/inc/sgx_capable.h)

Compile this script by running
```bash
$ sudo gcc enable_sw_sgx.cpp -o enable_sw_sgx -L. -lsgx_capable
```

The output should look something like:
```bash
$ sudo LD_LIBRARY_PATH=. ./enable_sw_sgx
is_sgx_capable: 1
status: 1
```
`is_sgx_capable` is a boolean value. If it's `0`, your machine is not sgx capable, so it must be `1`, otherwise this script will not work.
The meaning of the value `status` is listed here:
```cpp
* SGX_ENABLED = 0 /* All is good, sgx is enabled */
* SGX_DISABLED_REBOOT_REQUIRED = 1, /* A reboot is required to finish enabling SGX */
* SGX_DISABLED_LEGACY_OS = 2, /* SGX is disabled and a Software Control Interface is not available to enable it */
* SGX_DISABLED = 3, /* SGX is not enabled on this platform. More details are unavailable. */
* SGX_DISABLED_SCI_AVAILABLE = 4, /* SGX is disabled, but a Software Control Interface is available to enable it */
* SGX_DISABLED_MANUAL_ENABLE = 5, /* SGX is disabled, but can be enabled manually in the BIOS setup */
* SGX_DISABLED_HYPERV_ENABLED = 6, /* Detected an unsupported version of Windows* 10 with Hyper-V enabled */
* SGX_DISABLED_UNSUPPORTED_CPU = 7, /* SGX is not supported by this CPU */
```
## Check for FLC support
To use DCAP, the processor must support Flexible Launch Control (FLC). To check if that's the case you can do the following:

On a Linux* system, execute [cpuid](http://manpages.ubuntu.com/manpages/cosmic/man1/cpuid.1.html) in a terminal:
- Open a terminal and run: `$ cpuid | grep -i sgx`
- Look for output: `SGX_LC: SGX launch config supported = true`

More information / ways to check for FLC support can be found directly on the [intel homepage](https://www.intel.com/content/www/us/en/support/articles/000057420/software/intel-security-products.html).

# Intel SGX driver not available anymore
If the system was updated (for example due to a restart), it may be that the intel sgx driver is not reloaded and no sgx-device is available anymore.

The kernel version can be checked with:
```bash
$ uname -r
```

The installed intel SGX driver can be checked with:
```bash
$ cat /opt/intel/installed-intel-sgx-driver-version.txt
```
If the kernel version on the file and uname are different, the driver needs to be reinstalled. To do this, simple activate the
`role-intel-sgx` in the runbook and execute according to [Ansible Script Execution](https://github.com/integritee-network/sgx-setup#ansible-script-execution).

After a login, the driver should be installed for the correct version. A reboot is not necessary.


# Uninstall Intel SGX
To uninstall the following steps need to be done:
1. Uninstall sgxsdk
```bash
$ cd /opt/intel/sgxsdk
$ sudo ./uninstall.sh
$ cd /opt/intel/sgxsdk
```
2. Uninstall AESM
```bash
$ sudo service aesmd stop
$ sudo apt remove sgx-aesm-service
```
3. Uninstall driver
```bash
$ cd /opt/intel/sgxdriver
$ sudo ./uninstall.sh
```
and finally remove the intel folder and other left overs:
```bash
$ sudo rm -rf /opt/intel
$ sudo apt remove '^sgx-.*' '^libsgx-.*'
$ sudo apt autoremove
```
In case an older version of the OOT driver has been installed and no uninstall script is available, run the following steps:
```bash
$ sudo /sbin/modprobe -r isgx
$ sudo rm -rf "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"
$ sudo /sbin/depmod
$ sudo /bin/sed -i '/^isgx$/d' /etc/modules
```
(see https://github.com/intel/linux-sgx-driver#uninstall-the-intelr-sgx-driver)
