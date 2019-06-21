#!/usr/bin/env bash

yum upgrade -y
yum -y install epel-release && yum -y install net-tools bind-utils wget unzip
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
yum install -y nodejs && yum install -y gcc-c++ make vim expect telnet strace
npm install pm2 -g && pm2 completion install
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
systemctl restart sshd
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm"
yum localinstall -y jdk-8u191-linux-x64.rpm
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_191-amd64/jre' >> ~/.bash_profile && source ~/.bash_profile
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_191-amd64/jre' >> /home/vagrant/.bash_profile
cd /usr/local/src && wget http://www-us.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
tar -xf apache-maven-3.5.4-bin.tar.gz && rm -rf apache-maven-3.5.4-bin.tar.gz
mv apache-maven-3.5.4/ apache-maven/
cat <<'EOF' > /etc/profile.d/maven.sh
# Apache Maven Environment Variables
# MAVEN_HOME for Maven 1 - M2_HOME for Maven 2
export M2_HOME=/usr/local/src/apache-maven
export PATH=${M2_HOME}/bin:${PATH}
EOF

chmod +x /etc/profile.d/maven.sh && source /etc/profile.d/maven.sh

