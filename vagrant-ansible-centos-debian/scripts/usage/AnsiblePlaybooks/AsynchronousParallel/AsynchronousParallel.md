#### Execute slow async Playbook:
```bash
$ time ansible-playbook slow_playbook04.yml
$ ps waux|grep ansible
```

#### Execute one task only in the two hosts (**serial: 2**):
```bash
$ ansible-playbook slow_playbook10.yml
```

#### Execute by increment for each of host (**serial: -1 -2 -3*):
```bash
$ ansible-playbook slow_playbook11.yml
```
