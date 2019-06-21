# -*- mode: ruby -*-
# vi: set ft=ruby :
 
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.define "JenkMaster" do |subconfig|
      subconfig.vm.box = "alan-mangroo/JenkinNexus"
      subconfig.vm.hostname = "jenkmaster"
      subconfig.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 8265", ip: "192.168.106.100"
      subconfig.vm.provision :shell, :path => "scripts-tepms/global-provision.sh"
      subconfig.vm.provision :shell, :path => "scripts-tepms/jmaster-provision.sh"
  end
 
  config.vm.define "JenkinsSlave1" do |subconfig|
      subconfig.vm.box = "ubuntu/xenial64"
      subconfig.vm.hostname = "jenkslave1"
      subconfig.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 8265", ip: "192.168.106.210"
      subconfig.vm.network "forwarded_port", guest: 10080, host: 10080
      subconfig.vm.provision :shell, :path => "scripts-tepms/global-provision.sh"
      subconfig.vm.provision :shell, :path => "scripts-tepms/jslave-provision.sh"
  end
 
  config.vm.define "JenkinsSlave2" do |subconfig|
      subconfig.vm.box = "ubuntu/xenial64"
      subconfig.vm.hostname = "jenkslave2"
      subconfig.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 8265", ip: "192.168.106.220"
      subconfig.vm.provision :shell, :path => "scripts-tepms/global-provision.sh"
      subconfig.vm.provision :shell, :path => "scripts-tepms/jslave-provision.sh"
  end
 
  config.vm.define "GitLab" do |subconfig|
      subconfig.vm.box = "gutocarvalho/centos7x64gitlab"
      subconfig.vm.hostname = "gitlab"
      subconfig.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 8265", ip: "192.168.106.230"
      subconfig.vm.provision :shell, :path => "scripts-tepms/global-provision.sh"
      subconfig.vm.provider "virtualbox" do |virtualbox|
        virtualbox.customize [ "modifyvm", :id, "--cpus", "2" ]
        virtualbox.customize [ "modifyvm", :id, "--memory", "2048" ]
      end
  end

  config.vm.define "GoGS" do |subconfig|
      subconfig.vm.box = "ubuntu/xenial64"
      subconfig.vm.hostname = "gogs"
      subconfig.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 8265", ip: "192.168.106.232"
      subconfig.vm.provision :shell, :path => "scripts-tepms/global-provision.sh"
      subconfig.vm.provision "shell", path: "scripts-tepms/gogs-provision.sh"
      subconfig.vm.provider "virtualbox" do |virtualbox|
        virtualbox.customize [ "modifyvm", :id, "--cpus", "2" ]
        virtualbox.customize [ "modifyvm", :id, "--memory", "2048" ]
      end
  end
 
  config.vm.define "WebDeploySRV" do | subconfig|
      subconfig.vm.box = "ubuntu/xenial64"
      subconfig.vm.hostname = "websrv"
      subconfig.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 8265", ip: "192.168.106.240"
      subconfig.vm.provision :shell, :path => "scripts-tepms/global-provision.sh"
      subconfig.vm.provision :shell, :path => "scripts-tepms/websrv-provision.sh"
  end
end
