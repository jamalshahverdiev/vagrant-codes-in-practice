#!/usr/bin/env bash

apt update && apt dist-upgrade -y

sed -i 's/"syntax on/syntax on/g' /etc/vim/vimrc
echo 'set mouse-=a' > ~/.vimrc && source ~/.vimrc
echo "alias ll='ls -ltrh'" >>  /root/.bash_profile && source /root/.bash_profile
apt install -y net-tools vim ntpdate tcpdump telnet ftp makepasswd curl jq
timedatectl set-timezone 'Asia/Baku' && ntpdate 0.asia.pool.ntp.org
#echo "username:newpass"|chpasswd
echo -e "freebsd\nfreebsd" | passwd root
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

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
