#!/usr/bin/env bash

yum update && yum upgrade -y

yum install -y bash-completion wget expect gcc-c++ make unzip nfs-utils java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64 net-tools bind-utils vim ntpdate tcpdump telnet ftp makepasswd curl jq
timedatectl set-timezone 'Asia/Baku' && ntpdate 0.asia.pool.ntp.org
echo -e "freebsd\nfreebsd" | passwd root
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
cat <<EOF >> /etc/ssh/sshd_config
Port 22
Port 10022
EOF

setenforce permissive && systemctl restart sshd
systemctl stop firewalld && systemctl disable firewalld
echo "export JAVA_HOME=/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-1.8.0-openjdk-)" >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-1.8.0-openjdk-)" >> /home/vagrant/.bashrc
#sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf

cat <<EOF >> /etc/hosts
127.0.0.1       localhost
192.168.9.21    centos1
192.168.9.22    centos2
192.168.9.23    centos3
192.168.9.11    debian1
192.168.9.12    debian2
192.168.9.13    debian3
192.168.9.41    controller
192.168.9.40    dnsmasq
EOF

echo  "The IP address to SSH: $(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }')"
