#!/usr/bin/env bash

useradd nexus && sudo echo 'nexus - nofile 65536' >> /etc/security/limits.conf
mkdir /app && cd /app
wget https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.14.0-04-unix.tar.gz
tar -xzvf nexus-3.14.0-04-unix.tar.gz && version=$(ls | grep -v tar.gz | grep 'nexus-' | cut -f'2,3' -d'-') && sudo ln -s nexus-$version nexus
ln -s /app/nexus/bin/nexus /etc/init.d/nexus
sed -i.bak 's/#run_as_user=""/run_as_user="nexus"/g' /app/nexus/bin/nexus.rc
chown -R nexus:nexus /app/nexus/ /app/sonatype-work && sudo chown nexus:nexus /etc/init.d/nexus
systemctl stop firewalld && sudo systemctl disable firewalld
chkconfig --add nexus && chkconfig --levels 345 nexus on
systemctl daemon-reload && service nexus start
## Login to http://serverIP:8081
## Login: admin , Password: admin123
