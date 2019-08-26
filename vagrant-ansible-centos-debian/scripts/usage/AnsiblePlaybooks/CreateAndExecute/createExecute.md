#### Get distribution of Linux:
```bash
$ ansible all -l centos3,debian3 -m setup -a 'filter=ansible_distribution*'
$ ansible-playbook nginx_playbook.yml
```
