
# Step by Step (Development Server)

There are two different `ansible.yml` files:
1. [BuildServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/BuildServersSGX.yml) : used for continuous build servers, not for active developing. Hence no user and other roles included.
2. [DevelopmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml) : used for development server that support muliple accounts.

In this tutorial, the development server is focused on. The following roles are executed:
- `role-install-tools`: Installs a basic toolbox necessary to install sgxsdk and driver. The tools that will be installed can be checked out [here](https://github.com/integritee-network/sgx-setup/blob/add-readme/sgx-ansible/roles/role-install-tools/tasks/main.yml).
- `role-andrewrothstein.gcc-toolbox`: Installs gcc, necessary to install sgxsdk and driver.
- `role-intel-sgx`: For more information take a look at its dedicated [README](https://github.com/integritee-network/sgx-setup/tree/add-readme/sgx-ansible/roles/role-intel-sgx)
- `role-singleplatform-eng.users`: Needed to set up user accounts. Not necessary to actually run a sgx-machine but is recommended in case of multiple users accessing the same machine.

The other roles (such as the munin-node, timezone and keyboard roles) are not yet tested for ubunutu 20.04 and might be outdated. They will most likely be updated at a later point of time. If urgently needed, take a look at https://github.com/geerlingguy , up-to-date ansible scripts should be found there.

## Requirements
* Ansible v2.8 is required on your HOST (provisioner) system.
* You must have `sshpass` installed on your HOST (provisioner) not on the GUEST (machine(s) being provisioned).
* the GUEST machine must be on Ubuntu 20.04 (still oparating on Ubuntu 18.04? Contact us, we have a script for that one as well)
* SGX must be enabled in your BIOS

## Steps

1. Add your server credentials as a file to the [sgx-setup/sgx-ansible/host_vars/](https://github.com/integritee-network/sgx-setup/tree/main/sgx-ansible/host_vars). An example host can be found in [sgx-ansible/host_vars/examplehost.domain-ad.example.ch.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/host_vars/examplehost.domain-ad.example.ch.yml). Set the `ansible_user` and `ansible_host` according to your sgx-server name:
    ```yml
    ansible_user: examplehost
    ansible_host: examplehost.domain-ad.example.ch
    ```
    Ignore the netplan, munin-node, pkcs12 and nginx information for now. This will only become important when actually setting up these tools, which is not yet supported in this tutorial.

2. Install the basic tools on your host system by running the ansible install-tools :
    1. Activate the [role-install-tools](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L19) in [DevelopmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml)
    2. Execute the script according to [Ansible Script Execution](https://github.com/integritee-network/sgx-setup/tree/add-readme#ansible-script-execution).
3. Install gcc-tools by activating the [role-andrewrothstein.gcc-toolbox](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L20) (don't forget to recomment previously executed roles) and execute it, just like before.
4. Finally activate the [role-intel-sgx](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L22) and execute it as well. This might take some time (30 minutes on fast machines). In case the smoke tests have passed: Congratulation: You have successfully set up an sgx machine :)
 In case they did not, but the script executed without any errors, take a look at section [Check if sgx is enabled in BIOS](https://github.com/integritee-network/sgx-setup/tree/add-readme#check-if-sgx-is-enabled). If that is not the error, create an [issue](https://github.com/integritee-network/sgx-setup/issues/new) so we can try to help you out.
5. Seting up Users:
    1. Save the public key of the user in [sgx-setup/sgx-ansible/files/users/keys](https://github.com/integritee-network/sgx-setup/tree/main/sgx-ansible/files/users/keys), just like the  [example.users.pub](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/files/users/keys/example.user.pub)
    2. Note down the user in the [sgx-ansible/group_vars/developmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/group_vars/developmentServersSGX.yml), just like it has been done for the Example User.
    3. Activate the role in [role-singleplatform-eng.users](https://github.com/integritee-network/sgx-setup/blob/main/sgx-ansible/DevelopmentServersSGX.yml#L18) and execute it.


## Ansible Script Execution

To start the playbook, simply execute:
```bash
ansible-playbook site.yml -i sgxhosts -k
```
The option `-k` is used to ask for the connection (SSH) password. This will execute all activated roles in [DevelopmentServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/add-readme/sgx-ansible/DevelopmentServersSGX.yml) and [BuildServersSGX.yml](https://github.com/integritee-network/sgx-setup/blob/add-readme/sgx-ansible/BuildServersSGX.yml).

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
cd /opt/intel/linux-sgx_2.14/sdk/libcapable/linux/
sudo make
```
Then, in the same folder, create a script named `enable_sw_sgx.cpp` with the following content:
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
The functions `sgx_is_capable` and `sgx_cap_enable_device` are declared in `linux-sgx_2.14/common/inc/sgx_capable.h` and implemented in `linux-sgx_2.14/sdk/libcapable/linux/` (https://github.com/intel/linux-sgx/blob/master/common/inc/sgx_capable.h)

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

The meaning of the output value is listed here:
```cpp
* SGX_ENABLED = 0
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

# Intel sgx driver not available anymore
If the system was updated (for example due to a restart), it may be that the intel sgx driver is not reloaded and no sgx-device is available anymore.

The kernel version can be checked with:
```bash
$ uname -r
```

The installed intel sgx-driver can be checked with:
```bash
$ cat /opt/intel/installed-intel-sgx-driver-version.txt
```
If the kernel version on the file and uname are different, the driver needs to be reinstalled. To do this, simple activate the
`role-intel-sgx` in the runbook and execute according to [Ansible Script Execution](https://github.com/integritee-network/sgx-setup/tree/add-readme#ansible-script-execution).

After a login, the driver should be installed for the correct version. A reboot is not necessary.
