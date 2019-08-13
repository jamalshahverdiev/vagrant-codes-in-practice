#!/usr/bin/env bash

sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
yum clean all && yum update -y
yum -y install epel-release && yum -y install bash-completion net-tools bind-utils yum-utils wget telnet vim expect gcc-c++ make jq unzip nfs-utils sshpass policycoreutils-python git mc gcc python-devel python2-pip 
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf

systemctl start postfix && systemctl enable postfix
systemctl stop firewalld && sudo systemctl disable firewalld

yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
yum install -y postgresql10-server postgrseql10 postgresql-devel
rpm -Uvh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
yum install -y zabbix-agent
sed -i 's/Server=127.0.0.1/Server=10.3.55.100/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=PgSQLSrv/g' /etc/zabbix/zabbix_agentd.conf
systemctl enable zabbix-agent && systemctl restart zabbix-agent
