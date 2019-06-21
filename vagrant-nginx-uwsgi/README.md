#### Please change SSH path in Vagrantfile to yours with your own image or read the following instructions.

  - Download image with certificate which, are placed in in ssh-keys folder from [link](https://goo.gl/Oam3Ln).
  - Add new box file with "ub14x64" name to your box list. 
```sh
$ vagrant box add ub14x64 ub14x64.box
```
  - Clone this repository to your user home folder:
```sh
$ cd ~/
$ git clone https://github.com/jamalshahverdiev/vagrant-nginx-uwsgi.git ; cd vagrant-nginx-uwsgi
```
  - Put this certificates from the "ssh-keys" folder into your "~/.ssh" folder.
```sh
$ cp ssh-keys/* ~/.ssh/
```
  - Then start machines.
```sh
$ vagrant up
```
  - At the end send request to the load balancer IP address.
```sh
$ curl http://192.168.120.122
<h1 style='color:blue'>Hello ADA University!</h1>
```
