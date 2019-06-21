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
