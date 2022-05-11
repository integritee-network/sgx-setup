role-intel-sgx
=========

This ansible role installs Intel SGX DACP driver, SDK, PSW and AESM along with their dependencies. This playbook has been tested with Ansible v2.8 on Ubuntu 20.04

Requirements
------------
ansible

Role Variables
--------------
Intel sgx driver and SDK are now installed according to: <https://download.01.org/intel-sgx/sgx-linux/2.16/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf> (version 2.16)

The driver can be uninstalled with :
cd /opt/intel/{intel_DRIVER_version}/sgxdriver
Use uninstall script to uninstall the driver:
./uninstall.sh


The following variables at this implementation are received from the group_vars folder, so that they remain the same across different servers

intel_sgx_umbrella_directory: "/opt/intel"
This variable defines the directory where the Driver, SDK and PSW are installed.

intel_sgx_SDK_PWD_version: "2.14"
This variable defines the version of the SDK and PWD that will be installed. This has to be a valid version, for more info look at the official github page here: https://github.com/intel/linux-sgx/releases

intel_sgx_SDK_PWD_directory: "linux-sgx_{{ intel_sgx_SDK_PWD_version }}"
This variable defines the directory, where SDK and PWD. This directory is now associated with the sdk_version, to avoid overwriting a previous version with a newer one. However, it can be further modified, to install the same sdk version with possibly different make options.

intel_DRIVER_version: '1.41'
This variable defines the version of the sgx driver that will be installed. This has to be a valid version, for more info look at the official github page here: https://github.com/intel/linux-sgx-driver/releases

intel_sgx_DRIVER_directory: "linux-{{ intel_DRIVER_version }}_driver"
This variable defines the directory, where sgx driver. This directory is now associated with the sgx driver version, to avoid overwriting a previous version with a newer one. However, it can be further modified. Please not that to uninstall the SGX driver, follow the uninstalling description provided in https://download.01.org/intel-sgx/sgx-linux/2.16/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf


Dependencies
------------
The following dependencies are necessary for this role:
 - build-essential
 - ocaml
 - ocamlbuild
 - automake
 - autoconf
 - libtool
 - wget
 - python
 - libssl-dev
 - libcurl4-openssl-dev
 - protobuf-compiler
 - libprotobuf-dev
 - debhelper
 - cmake
 - expect

The role uses apt to install the above dependencies

Example Playbook
----------------
    - hosts: servers
      roles:
        - { role: role-intel-sgx, become: yes }
