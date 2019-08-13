#### Tu execute ansible commands under **vagrant** user just create **hosts** file with the following content:
```bash
$ cat hosts
[centos]
centos1 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant'
centos2 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant'
centos3 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant'

[debian]
debian1 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant'
debian2 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant'
debian3 ansible_ssh_user=vagrant ansible_ssh_pass='vagrant'
```

#### In the same folder will be stored **ansible.cfg** file with the following content: 
```bash
$ cat ansible.cfg
[defaults]
inventory = hosts
host_key_checking = False
```

#### Check connectivity between hosts:
```bash
$ ansible all -m ping
```
