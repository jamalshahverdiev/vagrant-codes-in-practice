#!/usr/bin/env bash

yum clean all && yum update -y
yum -y install epel-release 
yum update -y
yum -y install bash-completion \
	net-tools \
	bind-utils \
	wget \
	telnet \
	vim \
	expect \
	gcc-c++ \
	make \
	jq \
	unzip \
	nfs-utils \
	sshpass \
	yum-utils \
	device-mapper-persistent-data \
	lvm2 \
	python-pip \
	git \
	nc
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && yum install -y docker-ce
systemctl enable docker.service && systemctl start docker.service
usermod -aG docker $(whoami) && pip install --upgrade pip && pip install docker-compose flask
yum upgrade -y python*
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm"
yum localinstall -y /home/vagrant/jdk-8u191-linux-x64.rpm
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
systemctl stop firewalld && systemctl disable firewalld
sudo echo 'export JAVA_HOME=/usr/java/jdk1.8.0_191-amd64/bin' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_191-amd64/bin' >> /home/vagrant/.bashrc
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf 
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sudo useradd -m -d /home/$1 --shell=/sbin/nologin $1
sudo mkdir /etc/$1 && sudo chown -R $1:$1 /etc/$1

if [ "$(hostname)" = "nomadconsulagent1" -o "$(hostname)" = "nomadconsulagent2" ]
then
    sudo useradd -m -d /home/$2 --shell=/sbin/nologin $2
    sudo mkdir /etc/$2 && sudo chown -R $2:$2 /etc/$2
fi
