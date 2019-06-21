# -*- mode: ruby -*-
# vi: set ft=ruby :
current_dir = File.dirname(File.expand_path(__FILE__))

Vagrant.configure("2") do |config|
    config.vm.box = "ub14x64"
    (1..2).each do |i|
        config.vm.define "ngweb#{i}" do |web|
            web.vm.hostname = "ngweb#{i}"
            web.ssh.private_key_path = "~/.ssh/id_rsa"
            web.ssh.insert_key = "~/.ssh/id_rsa"
            web.ssh.forward_agent = true
            web.vm.synced_folder "#{current_dir}/temps", "/home/vagrant/temps", owner: "vagrant", group: "vagrant"
            web.vm.network :private_network, ip: "192.168.120.1#{i}"
            web.vm.network :forwarded_port, guest: 22, host: "1002#{i}", id: "ssh"
            web.vm.provider :virtualbox do |v1|
              v1.gui = true
              v1.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
              v1.customize ["modifyvm", :id, "--memory", 2048]
              v1.customize ["modifyvm", :id, "--name", "ngweb#{i}"]  
            end
            web.vm.provision :ansible do |ansible|
              ansible.playbook = "ngweb#{i}-playbook.yml"
            end
        end
    end

    config.vm.define "lb" do |lb1|
        lb1.vm.hostname = "lb"
        lb1.ssh.private_key_path = "~/.ssh/id_rsa"
        lb1.ssh.insert_key = "~/.ssh/id_rsa"
        lb1.ssh.forward_agent = true
	lb1.vm.synced_folder "#{current_dir}/temps", "/home/vagrant/temps", owner: "vagrant", group: "vagrant"
        lb1.vm.network :private_network, ip: "192.168.120.122"
        lb1.vm.network :forwarded_port, guest: 22, host: "10023", id: "ssh"
        lb1.vm.provider :virtualbox do |v2|
          v2.gui = true
          v2.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          v2.customize ["modifyvm", :id, "--memory", 2048]
          v2.customize ["modifyvm", :id, "--name", "lb"]
        end
        lb1.vm.provision :ansible do |ansible|
          ansible.playbook = "lb-playbook.yml"
        end
    end
     
end
