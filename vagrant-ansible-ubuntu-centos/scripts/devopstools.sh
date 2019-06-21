#!/usr/bin/env bash

rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

yum -y install gcc.x86_64 python36.x86_64 python36-pip.noarch azure-cli

python36 -m ensurepip
packs="pip
ansible
awscli
requests
paramiko
netmiko
bs4
simplejson
argparse"

export ANSIBLE_CONFIG=/root/ansible/ansible.cfg >> /root/.bashrc
mkdir /{etc,root}/ansible && touch /{etc,root}/ansible/ansible.cfg
touch /root/{.ansible,ansible}.cfg

for pipack in $packs
do
    python36 -m pip install --upgrade $pipack 
done
