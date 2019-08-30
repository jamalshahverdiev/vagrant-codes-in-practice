#### execute delegation:

```bash
$ cat hosts
[control]
controller ansible_connection=local

[centos]
centos1 ansible_ssh_pass='freebsd'
centos[2:3] ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022

[dns]
dnsmasq ansible_ssh_user=root ansible_ssh_pass='freebsd' ansible_ssh_port=22

[debian]
debian[1:3]:10022 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant'

[centos:vars]
ansible_ssh_user=root
ansible_become=true

[debian:vars]
ansible_become=true

[linux:children]
centos
debian

[linux:vars]
ansible_ssh_port=10022

[all:vars]
ansible_ssh_port=10022

$ ansible-playbook dynamic_dns_playbook05.yml
```
