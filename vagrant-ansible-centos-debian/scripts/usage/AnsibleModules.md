### The color format in the output like as following:
* **Green = Success** 
* **Yellow = Success with Changes**
* **Red = Failure**

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
