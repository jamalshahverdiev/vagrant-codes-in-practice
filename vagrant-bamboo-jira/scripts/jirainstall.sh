#!/usr/bin/env bash

yum -y install postgresql postgresql-server postgresql-contrib
postgresql-setup initdb

cat <<EOF> /var/lib/pgsql/data/postgresql.conf
listen_addresses = 'localhost'
port = 5432
max_connections = 300
shared_buffers = 80MB
logging_collector = on
log_filename = 'postgresql-%a.log'
log_truncate_on_rotation = on
log_rotation_age = 1d
log_rotation_size = 0
log_timezone = 'UTC'
datestyle = 'iso, mdy'
timezone = 'UTC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'
EOF

cat <<EOF> /var/lib/pgsql/data/pg_hba.conf
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 ident
EOF

echo 'kernel.shmmax = 18446744073692774399' >> /etc/sysctl.conf && sysctl -p
systemctl start postgresql && systemctl enable postgresql

su - postgres -c "psql -c \"CREATE DATABASE $1;\""
su - postgres -c "psql -c \"CREATE USER $1 WITH PASSWORD '$2';\""
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $1 TO $1;\""


useradd -m -d /home/$1 -c "Bamboo role account" --shell=/sbin/nologin $1 
mkdir /etc/$1 
cd /etc/$1 && wget https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.12.3-x64.bin
chmod +x atlassian-jira-software-7.12.3-x64.bin
echo -e "\n2\n/etc/jira\n\n1\n\n\n\n" | ./atlassian-jira-software-7.12.3-x64.bin --silent
#version=$(ls atlassian-bamboo-*.*.*.tar.gz | awk -F '-' '{ print $3}' | sed 's/.tar.gz//g')
#tar -zxvf atlassian-bamboo-$version.tar.gz && ln -s atlassian-bamboo-$version current
#echo "$1.home=/var/atlassian/application/$1" >> /etc/$1/current/atlassian-$1/WEB-INF/classes/$1-init.properties
#mkdir -p /var/atlassian/application/$1 /var/run/$1 && chown -R $1:$1 /etc/$1 /var/run/$1 /var/atlassian/application/$1/

#cat <<EOF> /etc/systemd/system/$1.service
#[Unit]
#Description=BAMBOO CICD Service
#Requires=network-online.target
#After=network-online.target
#
#[Service]
#WorkingDirectory=/etc/$1/current/bin
#ExecStartPre=-/bin/mkdir -p /var/run/$1
#ExecStartPre=/bin/chown -R $1:$1 /var/run/$1
#ExecStart=/bin/bash -c "/usr/bin/java -Djava.util.logging.config.file=/etc/$1/current/conf/logging.properties \
#	-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
#	-Xms512m -Xmx1024m -Djdk.tls.ephemeralDHKeySize=2048 \
#	-Djava.endorsed.dirs=/etc/$1/current/endorsed \
#	-classpath /etc/$1/current/bin/bootstrap.jar:/etc/$1/current/bin/tomcat-juli.jar \
#	-Dcatalina.base=/etc/$1/current -Dcatalina.home=/etc/$1/current \
#	-Djava.io.tmpdir=/etc/$1/current/temp org.apache.catalina.startup.Bootstrap start 2>&1 >> /etc/$1/current/logs/$1.log & echo \$! > /var/run/$1/$1.pid"
#PIDFile=/var/run/$1/$1.pid
#PermissionsStartOnly=true
#ExecReload=/bin/kill -HUP \$MAINPID
#KillMode=process
#KillSignal=SIGTERM
#Restart=on-failure
#RestartSec=42s
#Type=simple
#User=$1
#Group=$1
#
#[Install]
#WantedBy=multi-user.target
#EOF
#
#systemctl daemon-reload
#systemctl enable bamboo && systemctl start bamboo
