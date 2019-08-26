#### Stop nmginx service:
```bash
$ ansible centos3 -m service -a 'name=nginx state=stopped'
```

#### After previous command the following playbook will ait until port 80 start to listen:
```bash
$ ansible-playbook wait_for_playbook.yml
$ ansible-doc wait_for 
```
