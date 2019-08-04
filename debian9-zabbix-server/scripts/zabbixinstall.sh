#!/usr/bin/env bash

apt -y install software-properties-common dirmngr
apt-get install apache2 libapache2-mod-php7.0 php7.0 php7.0-xml php7.0-bcmath php7.0-mbstring -y
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64] http://www.ftp.saix.net/DB/mariadb/repo/10.1/debian stretch main'
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mariadb-server mysql-server/root_password password freebsd"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password freebsd"
apt-get install mariadb-server -y
systemctl start apache2 && systemctl enable apache2
wget http://repo.zabbix.com/zabbix/3.0/debian/pool/main/z/zabbix-release/zabbix-release_3.0-2+stretch_all.deb
dpkg -i zabbix-release_3.0-2+stretch_all.deb
apt-get update -y
apt-get install zabbix-server-mysql zabbix-frontend-php -y
apt-get install zabbix-agent -y
systemctl start zabbix-agent && systemctl enable zabbix-agent
systemctl start mariadb && systemctl enable mariadb

##wget http://repo.zabbix.com/zabbix/4.3/debian/pool/main/z/zabbix-release/zabbix-release_4.3-1%2Bstretch_all.deb
##dpkg -i zabbix-release_4.3-1+stretch_all.deb
mysql -uroot -p'freebsd' -e "create database zabbixdb;"
mysql -uroot -p'freebsd' -e "CREATE user zabbixuser identified by 'freebsd';"
mysql -uroot -p'freebsd' -e "GRANT ALL PRIVILEGES on zabbixdb.* to zabbixuser@localhost identified by 'freebsd';"
mysql -uroot -p'freebsd' zabbixdb -e "set global innodb_large_prefix=on"
mysql -uroot -p'freebsd' zabbixdb -e "set global innodb_file_format=Barracuda;"
mysql -uroot -p'freebsd' zabbixdb -e "set global innodb_file_per_table=true;"
mysql -uroot -p'freebsd' zabbixdb -e "set global innodb_default_row_format=dynamic;"
mysql -uroot -p'freebsd' -e "FLUSH PRIVILEGES;"

cd /usr/share/doc/zabbix-server-mysql*/ && gunzip create.sql.gz
mysql -u zabbixuser -p'freebsd' zabbixdb < create.sql

sed -i 's/php_value post_max_size 16M/php_value post_max_size 32M/g' /etc/zabbix/apache.conf
sed -i 's/php_value upload_max_filesize 2M/php_value upload_max_filesize 8M/g' /etc/zabbix/apache.conf
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Asia\/Baku/g' /etc/zabbix/apache.conf

sed -i 's/# DBHost=localhost/DBHost=localhost/g' /etc/zabbix/zabbix_server.conf
sed -i 's/DBName=zabbix/DBName=zabbixdb/g' /etc/zabbix/zabbix_server.conf
sed -i 's/DBUser=zabbix/DBUser=zabbixuser/g' /etc/zabbix/zabbix_server.conf
sed -i 's/# DBPassword=/DBPassword=freebsd/g' /etc/zabbix/zabbix_server.conf
systemctl restart apache2 && systemctl restart mysql && systemctl restart zabbix-server

wget http://repo.zabbix.com/zabbix/3.0/debian/pool/main/z/zabbix-release/zabbix-release_3.0-2+stretch_all.deb
dpkg -i zabbix-release_3.0-2+stretch_all.deb
apt-get update -y
apt-get install zabbix-agent -y
sed -i 's/ServerActive=127.0.0.1/ServerActive=10.3.55.100/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=ZabbixServer/g' /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent && systemctl enable zabbix-agent
