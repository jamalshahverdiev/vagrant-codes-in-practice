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
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
10.3.56.200   fswebsrv
10.3.56.11    fssrv1
10.3.56.12    fssrv2
10.3.56.50    fspgsql
10.3.56.100   propbx.loc
10.3.56.200   procall.loc
EOF

echo  "The IP address to SSH: $(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }')"
