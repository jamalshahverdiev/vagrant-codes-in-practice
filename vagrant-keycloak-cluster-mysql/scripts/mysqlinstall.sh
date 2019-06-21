#!/usr/bin/env bash

mysqlrepoVersion="mysql57-community-release-el7-9.noarch.rpm"
wget https://dev.mysql.com/get/$mysqlrepoVersion && yum localinstall -y $mysqlrepoVersion
yum install -y mysql-server
cp /vagrant/scripts/temps/my.cnf /etc/my.cnf
sed -i "s/mysqlIP/$1/g" /etc/my.cnf
systemctl enable mysqld && systemctl start mysqld

mysqlRootPass=$(cat /var/log/mysqld.log | grep 'A temporary password' | awk '{ print $(NF)}')
mysqlRootNew='CentOS123_'
if [ -n "$mysqlRootPass" ]
then
    mysqladmin -u root -p"$mysqlRootPass" password "$mysqlRootNew"
    mysql -uroot -p"$mysqlRootNew" -e "CREATE DATABASE $2;"
    mysql -uroot -p"$mysqlRootNew" -e "GRANT ALL PRIVILEGES ON $2.* TO '$2'@'%' IDENTIFIED BY '$3';"
else
      echo "\$mysqlRootPass is an empty variable"
fi

