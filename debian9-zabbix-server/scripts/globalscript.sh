#!/usr/bin/env bash

apt update && apt dist-upgrade -y

sed -i 's/"syntax on/syntax on/g' /etc/vim/vimrc
echo 'set mouse-=a' > ~/.vimrc && source ~/.vimrc
echo "alias ll='ls -ltrh'" >>  /root/.bash_profile && source /root/.bash_profile
apt install -y net-tools vim tcpdump telnet ftp makepasswd
#echo "username:newpass"|chpasswd
echo -e "freebsd\nfreebsd" | passwd root
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

echo  "The IP address to SSH: $(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }')"
