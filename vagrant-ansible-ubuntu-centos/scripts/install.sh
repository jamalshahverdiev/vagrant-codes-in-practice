#!/usr/bin/env bash

getOs=$(cat /etc/issue | head -n1 | awk '{ print $1 }')

cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.43.100 anssrv
10.1.43.11 centos1
10.1.43.12 centos2
10.1.43.13 centos3
10.1.43.21 ubuntu1
10.1.43.22 ubuntu2
10.1.43.23 ubuntu3
EOF

sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

centosInstall () {
  yum clean all && yum update -y
  yum -y install epel-release && yum -y install bash-completion net-tools bind-utils wget telnet vim expect gcc-c++ make jq unzip nfs-utils sshpass java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64 curl policycoreutils-python openssh-server postfix git xorg-x11-xinit.x86_64 xorg-x11-xinit-session.x86_64 xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps
  sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf
  
  systemctl start postfix && systemctl enable postfix
  systemctl stop firewalld && sudo systemctl disable firewalld
  
  echo "export JAVA_HOME=/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-1.8.0-openjdk-)" >> ~/.bashrc
  echo "export JAVA_HOME=/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-1.8.0-openjdk-)" >> /home/vagrant/.bashrc
}

ubuntuInstall (){
    export DEBIAN_FRONTEND=noninteractive
    apt update && apt dist-upgrade -y
}

if [ "$getOs" = "Ubuntu" ]
then
    ubuntuInstall
else
    centosInstall
fi

