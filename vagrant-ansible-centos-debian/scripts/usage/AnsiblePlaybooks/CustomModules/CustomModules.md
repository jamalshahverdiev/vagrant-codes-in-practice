#### Clone Ansible source code files:
```bash
$ mkdir ~/src && cd ~/src
$ git clone https://github.com/ansible/ansible.git
$ ansible/hacking/test-module -m ansible/lib/ansible/modules/commands/command.py -a hostname
```

#### Check test module:
```bash
$ ~/src/ansible/hacking/test-module -m ./icmp.sh -a 'target=127.0.0.1'
$ ~/src/ansible/hacking/test-module -m ./icmp.sh
* including generated source, if any, saving to: /root/.ansible_module_generated
***********************************
RAW OUTPUT
{"changed": true, "rc": 0}


***********************************
PARSED OUTPUT
{
    "changed": true,
    "rc": 0
}

$ cat icmp.sh
#!/bin/bash

ping -c 1 127.0.0.1 >/dev/null 2>/dev/null

if [ $? == 0 ];
  then
  echo "{\"changed\": true, \"rc\": 0}"
else
  echo "{\"failed\": true, \"msg\": \"failed to ping\", \"rc\": 1}"
fi
```

#### Split screen with TMUX and execute Ansible command in different console:
```bash
$ watch -n0.1 --differences 'ps -ef | grep ansibl[e]'
$ ~/src/ansible/hacking/test-module -m ./icmp.sh -a 'target=128.0.0.1'
root     13309  5432 10 20:04 pts/2    00:00:00 python /root/src/ansible/hacking/test-module -m ./icmp.sh -a target=128.0.0.1
root     13323 13309  0 20:04 pts/2    00:00:00 /bin/sh -c /root/.ansible_module_generated /root/.ansible_test_module_arguments
root     13324 13323  0 20:04 pts/2    00:00:00 /bin/bash /root/.ansible_module_generated /root/.ansible_test_module_arguments
```

#### Check with PYTHON:
```bash
$ ~/src/ansible/hacking/test-module -m ./icmp.py -a 'target=128.0.0.1'
```
