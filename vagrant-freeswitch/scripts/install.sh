#!/usr/bin/env bash

echo 'http_caching=packages' >> /etc/yum.conf
yum upgrade -y
yum -y install epel-release && sudo yum -y install net-tools bind-utils wget gcc-c++ make vim expect telnet strace
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.rpm"
yum localinstall -y jdk-8u201-linux-x64.rpm

systemctl stop firewalld && sudo systemctl disable firewalld
echo 'export JAVA_HOME=/usr/java/jre1.8.0_201-amd64/bin/java' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/java/jre1.8.0_201-amd64/bin/java' >> /home/vagrant/.bashrc
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf
