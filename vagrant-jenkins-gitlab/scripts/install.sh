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

if [ "$(hostname)" = "pg1" -o "$(hostname)" = "pg2" -o "$(hostname)" = "pg3" ]
then
cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.42.141 pg1
10.1.42.142 pg2
10.1.42.143 pg3
EOF
fi

if [ "$(hostname)" = "backend1" -o "$(hostname)" = "backend2" ]
then
    yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    yum install -y gcc-c++ make postgresql11
    yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    yum install -y yum-utils && yum-config-manager --enable remi-php72
cat <<'EOF' > /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
EOF
    yum install -y php72-php.x86_64 php72-php-pecl-apcu.x86_64 php72-php-bcmath.x86_64 php72-php-cli.x86_64 php72-php-fpm.x86_64 php72-php-gd.x86_64 php72-php-intl.x86_64 php72-php-json.x86_64 php72-php-ldap.x86_64 php72-php-mbstring.x86_64 php72-php-opcache.x86_64 php72-php-pdo.x86_64 php72-php-pgsql.x86_64 php72-php-soap.x86_64 php72-php-xml.x86_64 php72-php-xmlrpc.x86_64 php72-php-pecl-zip.x86_64 php72-runtime.x86_64 php72-php-common.x86_64 nginx dnsmasq.x86_64 ntpdate
    ln -s /bin/php72 /bin/php
    curl -sL https://rpm.nodesource.com/setup_12.x | bash - && yum install -y nodejs
fi

yes | cp -rf /vagrant/scripts/motd /etc/motd
