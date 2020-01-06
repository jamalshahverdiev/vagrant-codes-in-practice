#!/usr/bin/env bash
yum clean all && yum update -y
yum -y install epel-release && yum -y install bash-completion git net-tools bind-utils wget telnet vim expect gcc-c++ make jq unzip nfs-utils sshpass java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64 curl policycoreutils-python openssh-server postfix
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf

systemctl start postfix && systemctl enable postfix
systemctl restart sshd
systemctl stop firewalld && sudo systemctl disable firewalld

echo "export JAVA_HOME=/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-1.8.0-openjdk-)" >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-1.8.0-openjdk-)" >> /home/vagrant/.bashrc

if [ "$(hostname)" = "consulsrv1" -o "$(hostname)" = "consulsrv2" -o "$(hostname)" = "consulsrv3" ]
then
    useradd -m -d /home/$1 --shell=/sbin/nologin $1
    mkdir /etc/$1 /var/run/$1 /var/log/$1 && chown -R $1:$1 /etc/$1 /var/run/$1 /var/log/$1
fi

if [ "$(hostname)" = "pgsrv1" -o "$(hostname)" = "pgsrv2" -o "$(hostname)" = "pgsrv3" ]
then
cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.42.141 pg1
10.1.42.142 pg2
10.1.42.143 pg3
EOF
fi

yes | cp -rf /vagrant/scripts/motd /etc/motd
