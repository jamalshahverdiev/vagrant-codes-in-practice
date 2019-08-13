#### Tu execute ansible commands under **vagrant** user just create **hosts** file with the following content:
```bash
$ cat hosts
[centos]
centos1 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022 ansible_become=true
centos2 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022 ansible_become=true
centos3 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022 ansible_become=true

[debian]
debian1 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022 ansible_become=true
debian2 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022 ansible_become=true
debian3 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022 ansible_become=true
```

#### In the same folder will be stored **ansible.cfg** file with the following content: 
```bash
$ cat ansible.cfg
[defaults]
interpreter_python = /usr/bin/python
inventory = hosts
host_key_checking = False
```

#### Check connectivity between hosts:
```bash
$ ansible all -m ping
```
