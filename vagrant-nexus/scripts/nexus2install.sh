#!/usr/bin/env bash

#yum install -y java-1.8.0-openjdk.x86_64
mkdir /opt/nexus && cd /opt/nexus
cd /opt/nexus
wget http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz
tar -xzvf nexus-latest-bundle.tar.gz && version=$(ls | grep -v latest | grep 'nexus-' | cut -f'2,3' -d'-') && ln -s nexus-$version nexus
cp /opt/nexus/nexus/bin/nexus /etc/init.d/
sed -i.bak -e 's/NEXUS_HOME=\"..\"/NEXUS_HOME=\"\/opt\/nexus\/nexus\"/' /etc/init.d/nexus
sed -i.bak -e 's|nexus-webapp-context-path=/nexus|nexus-webapp-context-path=/|' /opt/nexus/nexus/conf/nexus.properties
useradd nexus
chown -R nexus:nexus /opt/nexus/ && sudo chown nexus:nexus /etc/init.d/nexus
sed -i.bak -e 's/#RUN_AS_USER=/RUN_AS_USER=nexus/' /etc/init.d/nexus
systemctl stop firewalld && sudo systemctl disable firewalld
echo 'RUN_AS_USER=nexus' >> /etc/environment && export RUN_AS_USER=nexus
systemctl daemon-reload
/etc/init.d/nexus start && chkconfig nexus on
## Login to http://serverIP:8081
## Login: admin , Password: admin123
