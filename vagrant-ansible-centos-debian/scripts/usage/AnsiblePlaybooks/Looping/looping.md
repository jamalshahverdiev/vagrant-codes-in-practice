#### Copy **id_rsa.pub** key for username **james** to the **authoirized_keys** file:
```bash
$ ansible-playbook user_playbook13.yml
```
#### Generate **custom_key** key pair (with the same name) in the same folder where will be executed the following command. It will copy **custom_key.pub** file to the remote **/home/james/authorized_keys** file for the **james** user (At the end just try to login with the key to one of the remote servers):
```bash
$ ansible-playbook ssh_key_playbook.yml
$ chmod 400 custom_key
$ ssh -i custom_key james@debian1
```

#### Create recursive directory structure:
```bash
$ ansible-playbook directory_sequence15.yml
```

