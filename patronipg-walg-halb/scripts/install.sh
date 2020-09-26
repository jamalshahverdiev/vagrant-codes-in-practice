#!/usr/bin/env bash
yum clean all && yum update -y
yum -y install epel-release && yum -y install git net-tools bind-utils wget telnet vim gcc-c++ make jq unzip sshpass 
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf

systemctl restart sshd
systemctl stop firewalld && sudo systemctl disable firewalld


if [ "$(hostname)" = "patpg1" -o "$(hostname)" = "patpg2" -o "$(hostname)" = "patpg3" ]
then
cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.42.141 patpg1
10.1.42.142 patpg2
10.1.42.143 patpg3
EOF
fi

yes | cp -rf /vagrant/scripts/motd /etc/motd
