[Online YAML Converter to JSON](http://yaml-online-parser.appspot.com/)

#### Use **setup** module to get Linux internal variable from gathering facts:
```bash
$ ansible centos1 -m setup
```

#### Create **/tmp/test** file in all Linux machines named under **linux** under inventory file:
```bash
$ ansible linux -m file -a 'path=/tmp/test state=touch'
```

#### Change the permission of the file **/tmp/test** to the **600** under linuxes grouped as **linux**:
```bash
$ ansible linux -m file -a 'path=/tmp/test state=file mode=600'
```

#### Copy from local source file **hosts.yml** to the remote destination **/tmp/hosts.yml** for all linuxes under **linux** group:
```bash
$ ansible linux -m copy -a 'src=./hosts.yml dest=/tmp/hosts.yml'
```

#### Copy from remote source file **/tmp/hosts.yml** to the remote destination **/tmp/hosts1.yml** for all linuxes under **linux** group:
```bash
$ ansible linux -m copy -a 'remote_src=yes src=/tmp/hosts.yml dest=/tmp/hosts1.yml'
```

#### Execute **df -h /** command inside of all linux servers under **linux** group and get response to the console:
```bash
$ ansible linux -m command -a 'df -h /' -o
```

#### Get UID of remote user for each os remote operation systems:
```bash
$ ansible linux -a 'id' -o
debian1 | CHANGED | rc=0 | (stdout) uid=0(root) gid=0(root) groups=0(root)
debian2 | CHANGED | rc=0 | (stdout) uid=0(root) gid=0(root) groups=0(root)
debian3 | CHANGED | rc=0 | (stdout) uid=0(root) gid=0(root) groups=0(root)
centos3 | CHANGED | rc=0 | (stdout) uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant)
centos2 | CHANGED | rc=0 | (stdout) uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant)
centos1 | CHANGED | rc=0 | (stdout) uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant)
```

#### Use command module to create file in remote systems:
```bash
$ ansible all -a 'touch /tmp/test_copy_module creates=/tmp/test_copy_module'
```

#### Remove remote file:
```bash
$ ansible all -a 'rm /tmp/test_copy_module1 removes=/tmp/test_copy_module1'
```

#### Remove file with file module:
```bash
$ ansible all -m file -a 'path=/tmp/test_copy_module state=absent'
```

#### Create file with mode in the remote **centos1** then fet this file from remote to the local:
```bash
$ ansible centos1 -m file -a 'path=/tmp/test_modules.txt state=touch mode=600'
$ ansible centos1 -m fetch -a 'src=/tmp/test_modules.txt dest=/tmp/test_modules.txt'
```

#### Look at the documentation of the **file** module with **ansible-doc** command:
```bash
$ ansible-doc file
```
