#### Playbook to copy **centos_motd** file to the centos servers as remote file to **/etc/motd**:
```bash
$ cat motd_playbook.yml
---
-
  hosts: linux
  vars:
    motd_centos: "Welcome to CentOS Linux - Ansible Rocks\n"
    motd_debian: "Welcome to Debian Linux - Ansible Rocks\n"
  tasks:
    - name: Configure a MOTD (message of the day)
      copy:
        content: "{{ motd_centos }}"
        dest: /etc/motd
      notify: MOTD changed
      when: ansible_distribution == "CentOS"

    - name: Configure a MOTD (message of the day)
      copy:
        content: "{{ motd_debian }}"
        dest: /etc/motd
      notify: MOTD changed
      when: ansible_distribution == "Debian"

  # Handlers: handlers that are executed as a notify key from a task
  handlers:
    - name: MOTD changed
      debug:
        msg: The MOTD was changed
...

$ cat ansible.cfg
[defaults]
interpreter_python = /usr/bin/python
inventory = hosts
host_key_checking = False
jinja2_extensions = jinja2.ext.loopcontrols
ansible_managed = Managed by Ansible - file:{file} - host:{host} - uid:{uid}

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

#### Execute playbook:
```bash
$ ansible-playbook motd_playbook.yml 
```

#### Change Internal variable with Extra variable from console:
```bash
$ ansible-playbook motd_playbook.yml  --extra-vars='motd_debian="Changed Welcome from extra Var"'
```

#### Find all distributions:
```bash
$ ansible linux -i hosts -m setup | grep '"ansible_distribution":'
```
