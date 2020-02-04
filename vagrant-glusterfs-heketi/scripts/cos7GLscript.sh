#!/usr/bin/env bash

yum update && yum upgrade -y

yum install -y bash-completion wget expect gcc-c++ make unzip nfs-utils net-tools bind-utils vim ntpdate tcpdump telnet ftp makepasswd curl jq
timedatectl set-timezone 'Asia/Baku' && ntpdate 0.asia.pool.ntp.org
echo -e "freebsd\nfreebsd" | passwd root
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

setenforce permissive && systemctl restart sshd
systemctl stop firewalld && systemctl disable firewalld

cat <<EOF >> /etc/hosts
192.168.10.41 heketi
192.168.10.21 prodgluster01
192.168.10.22 prodgluster02
192.168.10.23 prodgluster03
127.0.0.1     localhost
EOF
