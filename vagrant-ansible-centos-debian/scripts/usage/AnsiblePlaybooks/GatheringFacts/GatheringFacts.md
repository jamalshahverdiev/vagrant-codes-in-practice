#### Get Fact for the network:
```bash
$ ansible centos1 -m setup -a'gather_subset=network,!all,!min'
```

#### Print free memory of **centos1** server:
```bash
$ ansible centos1 -m setup -a 'filter=ansible_memfree_mb'
centos1 | SUCCESS => {
    "ansible_facts": {
        "ansible_memfree_mb": 620
    },
    "changed": false
}
$ ansible centos1 -m setup -a 'filter=ansible_mem*'
$ ansible debian1 -m setup -a 'filter=ansible_eth1'
```

#### Get IP address of all servers for the **eth1** network card:
```bash
$ ansible-playbook facts_playbook.yml
```

#### Create Facts folder and copy content of **templates** folder to the **/etc/ansible/facts.d** directory:
```bash
$ mkdir -p /etc/ansible/facts.d
$ cp templates/* /etc/ansible/facts.d/
```

#### Chech facts in the server where you put files to the **/etc/ansible/facts.d** folder:
```bash
$ ansible controller -m setup | tee /tmp/x
$ cat /tmp/x | grep getdate
$ ansible controller -m setup -a 'filter=ansible_local'
$ ansible-playbook facts_playbook.yml -l controller
$ ansible linux -m file -a 'path=/home/vagrant/ansible/facts.d state=absent'
```
