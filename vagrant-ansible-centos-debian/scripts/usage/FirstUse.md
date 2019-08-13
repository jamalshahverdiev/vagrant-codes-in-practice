#### Tu execute ansible commands under **vagrant** user just create **hosts** file with the following content:
```bash
$ cat hosts
[control]
controller ansible_connection=local

[centos]
centos1 ansible_ssh_pass='freebsd'
centos[2:3] ansible_ssh_user=vagrant ansible_ssh_pass='vagrant' ansible_ssh_port=10022

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
```

#### In the same folder will be stored **ansible.cfg** file with the following content: 
```bash
$ cat ansible.cfg
[defaults]
interpreter_python = /usr/bin/python
inventory = hosts
host_key_checking = False
```

#### To use inventory file from the YAML file just define **hosts.yml** file in the **ansible.cfg** file like as following:
```bash
$ cat ansible.cfg
[defaults]
interpreter_python = /usr/bin/python
inventory = hosts.yml
host_key_checking = False
```

#### Inventory YAML file will be as the folliwing:
```bash
$ cat hosts.yml
---
control:
  hosts:
    controller:
      ansible_connection: local
centos:
  hosts:
    centos1:
      ansible_port: 10022
    centos2:
    centos3:
  vars:
    ansible_user: root
debian:
  hosts:
    debian1:
    debian2:
    debian3:
  vars:
    ansible_become: true
    ansible_become_pass: vagrant
linux:
  children:
    centos:
    debian:
...
```

#### The same thing for the JSON file:
```bash
$ cat hosts.json
{
    "control": {
        "hosts": {
            "controller": {
                "ansible_connection": "local"
            }
        }
    },
    "debian": {
        "hosts": {
            "debian1": null,
            "debian2": null,
            "debian3": null
        },
        "vars": {
            "ansible_become": true,
            "ansible_ssh_user": "vagrant",
            "ansible_ssh_pass": "vagrant",
            "ansible_ssh_port": 10022,
            "ansible_become_pass": "vagrant"
        }
    },
    "centos": {
        "hosts": {
            "centos3": null,
            "centos2": null,
            "centos1": {
                "ansible_become": true,
                "ansible_ssh_user": "vagrant",
                "ansible_ssh_pass": "vagrant",
                "ansible_ssh_port": 10022,
                "ansible_become_pass": "vagrant"
            }
        },
        "vars": {
            "ansible_ssh_user": "root",
            "ansible_ssh_pass": "freebsd"
        }
    },
    "linux": {
        "children": {
            "centos": null,
            "debian": null
        }
    }
}
```

#### Check connectivity between hosts for **all** and **linux** group:
```bash
$ ansible all -m ping -o
$ ansible linux -m ping -o
$ ansible all -i hosts.yml -m ping -o
$ ansible all -i hosts.json -m ping -o
$ ansible all -i hosts.json -e 'ansible_ssh_port=10022' -m ping -o
```

#### Look at hosts list:
```bash
$ ansible all --list-hosts
```
