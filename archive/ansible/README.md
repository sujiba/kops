# Ansible 

## Hetzner cloud config

```yaml
#cloud-config
package_update: true
package_upgrade: true
packages:
  - sudo
  - vim
users:
  - name: YOUR_USER
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - YOUR_KEY
runcmd:
  - reboot
```

## Configure host
```bash
ansible-playbook maulwurf/playbook.yaml -i "IP_ADDRESS,"
```
