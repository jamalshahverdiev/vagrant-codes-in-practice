#### Get list of all hosts from Python inventory file:
```bash
$ ansible all -i inventory.py --list-hosts
  hosts (7):
    controller
    centos1
    centos2
    centos3
    debian1
    debian2
    debian3
$ ansible all -i inventory.py -m ping
```
