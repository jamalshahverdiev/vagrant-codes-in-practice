*********************************************
Before read this document you must install and configure your Fedora24 desktop with vagrant and ansible.
*********************************************

============================
This document explain how to install and configure vagrant to use Vmware Vcenter. Firstly we must install and configure our virtual environment. I have 2 ESXI servers worked with clustered storage from FC storage
============================

* The configuration of vCenter as following:

    .. image:: images/vcenter-structure.png

* ESXI severs::

  10.50.94.8
  10.50.94.9

* Vcenter server::

  10.50.94.10

* ``dev`` is the resource pool. The name Cluster will be used in our Vagrantfile. Right click on the Cluster(or ``Ctrl+O``) and choose New Resource Pool. Select as default and write name is ``dev``:

    .. image:: images/create-resource-pool.png

* Right click on the dev resource pool and select New Virtual Machine (or **Ctrl+N**). Configure new virtual machine with you need and as operation system select CentOS7. Give name of virtual machine **cos7box**. Remove floppy device and select vlan for your network card in the DHCP subnet. Install your operation system as default with minimal installation. Set hostname **cos7box** and configure network card to start when system up. Disable IPv6. Set root password to **vagrant**:

    .. image:: images/linux-network-card-startup.png

After installation login to your Linux via ssh. 

* Update cache and packages::
  
  [root@cos7box ~]# yum makecache fast
  [root@cos7box ~]# yum update -y

* Disable Selinux, firewalld and do reboot your template system::
  
  [root@cos7box ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  [root@cos7box ~]# systemctl disable firewalld
  [root@cos7box ~]# reboot

* Install perl and needed packages because vmware-tools will be require::
  
  [root@cos7box ~]# yum -y install perl net-tools bind-utils vim

Install vmware-tools. In the console of virtual machine select ``VM -> Guest -> Install/Upgrade Vmware Tools`` 

* In the Linux console mount cdrom and install vmware-tools::
  
  [root@cos7box ~]# mount /dev/cdrom /media/
  mount: /dev/sr0 is write-protected, mounting read-only
  [root@cos7box ~]# cp /media/VMwareTools-10.0.0-3000743.tar.gz /root/
  [root@cos7box ~]# cd /root/; tar zxf VMwareTools-10.0.0-3000743.tar.gz ; cd vmware-tools-distrib/

* Answer the first question yes and select default to others(just press Enter button)::
  
  [root@cos7box vmware-tools-distrib]# ./vmware-install.pl
  open-vm-tools are available from the OS vendor and VMware recommends using
  open-vm-tools. See http://kb.vmware.com/kb/2073803 for more information.
  Do you still want to proceed with this legacy installer? [no] yes
  Enjoy,
  --the VMware team

* Select ``VM -> Edit Settings`` and change **cdrom** to Host Device:

    .. image:: images/unlock-cdrom.png

* Add new user vagrant and give password vagrant::
  
  [root@cos7box ~]# useradd -m vagrant
  [root@cos7box ~]# passwd vagrant
  Changing password for user vagrant.
  New password: vagrant
  BAD PASSWORD: The password is shorter than 8 characters
  Retype new password: vagrant
  passwd: all authentication tokens updated successfully.

* Give full access to vagrant user to use sudo::
  
  [root@cos7box ~]# visudo
  ## Allows members of the users group to shutdown this system
  #%users  localhost=/sbin/shutdown -h now
  Defaults:vagrant !requiretty
  vagrant ALL=(ALL) NOPASSWD:ALL

* Create SSH folder to this user and download vagrant public key to this folder::
  
  [root@cos7box ~]# mkdir -p /home/vagrant/.ssh
  [root@cos7box ~]# curl -k https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys


* Set SSH permissions to work without warnings::
  
  [root@cos7box ~]# chmod 0700 /home/vagrant/.ssh
  [root@cos7box ~]# chmod 0600 /home/vagrant/.ssh/authorized_keys
  [root@cos7box ~]# chown -R vagrant:vagrant /home/vagrant/.ssh

* Shutdown the virtual machine and create template in the vcenter console of this machine::

  [root@cos7box ~]# poweroff

* Right click on the virtual machine select Template and Convert to Template:

    .. image:: images/create-template.png



^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Install and configure vagrant with ansible to the Fedora desktop
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* Create folder for our Vagrantfile and go this folder::
  
  [jshahverdiev@cons2 ~]$ mkdir vsphere ; cd vsphere/

* Create temps folder for file syncronization and tasks folder for ansible playbooks::
  
  [jshahverdiev@cons2 ~]$ mkdir tasks/; cd temps/

* Create **cos7-playbook.yml** file with the following content(This file will include install_nginx.yml file from tasks folder to install/configure and start nginx)::
  
  [jshahverdiev@cons2 vsphere]$ cat cos7-playbook.yml 
  ---
  - hosts: all
    become: true
    tasks:
    - include: 'tasks/install_nginx.yml''

* Create tasks/install_nginx.yml file with the following content::
  
  [jshahverdiev@cons2 vsphere]$ cat tasks/install_nginx.yml 
  - name: NGINX | Installing NGINX repo rpm
    yum:
    name: http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
    
  - name: NGINX | Installing NGINX
    yum:
    name: nginx
    state: latest
    
  - name: NGINX | Starting NGINX
    service:
    name: nginx
    state: started 

* Install needed plugins::
  
  [jshahverdiev@cons2 vsphere]$ vagrant plugin install vagrant-vsphere  
  [jshahverdiev@cons2 vsphere]$ vagrant plugin install vagrant-guests-photon


* Create and add new box for vsphere::
  
  [jshahverdiev@cons2 vsphere]$ curl -k https://raw.githubusercontent.com/nsidc/vagrant-vsphere/master/example_box/metadata.json -O
  [jshahverdiev@cons2 vsphere]$ tar cvzf vsphere-dummy.box ./metadata.json 
  ./metadata.json
  [jshahverdiev@cons2 vsphere]$ vagrant box add vsphere-dummy ./vsphere-dummy.box
  ==> box: Box file was not detected as metadata. Adding it directly...
  ==> box: Adding box 'vsphere-dummy' (v0) for provider: 
      box: Unpacking necessary files from: file:///home/jshahverdiev/vsphere/vsphere-dummy.box
      ==> box: Successfully added box 'vsphere-dummy' (v0) for 'vsphere'!

* Look at box files::
  
  [jshahverdiev@cons2 vsphere]$ vagrant box list 
  ub14x64       (virtualbox, 0)
  vsphere-dummy (vsphere, 0)

* Create vagrantfile with the following contents::
  
  [jshahverdiev@cons2 vsphere]$ cat Vagrantfile 
  # -*- mode: ruby -*-
  # vi: set ft=ruby :

  ENV['VAGRANT_DEFAULT_PROVIDER'] = 'vsphere'
  current_dir = File.dirname(File.expand_path(__FILE__))
  
  Vagrant.configure("2") do |config|
   config.nfs.functional = false
   config.vm.define "cos7" do |cos7|
    cos7.vm.provider :vsphere do |vsphere|
      # The IP address or name of Vcenter server
      vsphere.host = '10.50.94.10'
      # The domain name of ESXI hosts
      vsphere.compute_resource_name = 'Cluster'
      # The name of Resource pool which we created before
      vsphere.resource_pool_name = 'dev'
      # The name of Template file which we created before
      vsphere.template_name = 'cos7box'
      # The name of new virtual machine
      vsphere.name = 'centos7.vagbox'
      # Username of vcenter 
      vsphere.user = 'administrator@vsphere.local'
      # Password for vcenter
      vsphere.password = 'A123456789a!'
      vsphere.insecure = true
    end
    cos7.vm.box = "vsphere-dummy"
    # The name of box file which we already created
    cos7.vm.hostname = "cos7"
    # Playbook file which will install and configure nginx server
    cos7.vm.provision :ansible do |ansible|
      ansible.playbook = "cos7-playbook.yml"
    end
    # Syncronize folder to the virtual machine
    cos7.vm.synced_folder "#{current_dir}/temps", "/home/vagrant/temps", owner: "vagrant", group: "vagrant"
   end
  end  

* Use the following command to start new virtual machine and install nginx to this virtual machine(If you want to debug use the vagrant up **--debug** command)::
  
  [jshahverdiev@cons2 vsphere]$ vagrant up

* Try to login to the virtual machine::
  
  [jshahverdiev@cons2 vsphere]$ vagrant ssh cos7
