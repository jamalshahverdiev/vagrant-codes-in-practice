#### Playbook to copy **centos_motd** file to the centos servers as remote file to **/etc/motd**:
```bash
$ cat motd_playbook.yml
---
# YAML documents begin with the document separator ---

# The minus in YAML this indicates a list item.  The playbook contains a list
# of plays, with each play being a dictionary
-

  # Target: where our play will run and options it will run with
  hosts: centos
  user: root

  # Variable: variables that will apply to the play, on all target systems

  # Task: the list of tasks that will be executed within the playbook
  tasks:
    - name: Configure a MOTD (message of the day)
      copy:
        src: centos_motd
        dest: /etc/motd

  # Handlers: handlers that are executed as a notify key from a task

  # Roles: list of roles to be imported into the play

# Three dots indicate the end of a YAML document
...
$ cat ansible.cfg
[defaults]
interpreter_python = /usr/bin/python
inventory = hosts
host_key_checking = False

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
