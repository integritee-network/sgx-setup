This ansible playbook was used to configure the SGX Linux Server.

To execute the playbook, simply execute:
```bash
ansible-playbook site.yml -i sgxhosts -k
```
The option `-k` is used to ask for the connection (SSH) password.

## Requirements
* Ansible v2.8 is required
* You must have `sshpass` installed on your HOST (provisioner) not on the GUEST (machine(s) being provisioned).

## List affected hosts and dry-run
To show which host will be provisioned, execute the upper command with the option `--list-hosts`.

To do a dry-run, execute the upper command with the options `--check --diff`.

## Only update one host
Use the command to only update the host `examplehost*`:
```bash
ansible-playbook site.yml -i sgxhosts -l "examplehost*" -k
```
