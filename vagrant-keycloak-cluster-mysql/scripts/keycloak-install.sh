#!/usr/bin/env bash

if [ -z "$(cat /etc/passwd | grep $2 | cut -f1 -d':')" ]
then
    useradd -s /sbin/nologin $2
    if [ ! -d "/app" ]
    then
        mkdir -p /app 
    fi
fi

cp /vagrant/scripts/temps/$2.service /etc/systemd/system/
sed -i "s/userName/$2/g" /etc/systemd/system/$2.service
wget https://downloads.jboss.org/$2/4.3.0.Final/$2-4.3.0.Final.tar.gz 
tar -zxvf $2-4.3.0.Final.tar.gz && mv $2-4.3.0.Final /app/$2
mkdir -p /app/$2/modules/system/layers/base/com/mysql/main /app/$2/pid
wget https://cdn.mysql.com/Downloads/Connector-J/mysql-connector-java-8.0.$5.zip
unzip mysql-connector-java-8.0.$5.zip 
cp mysql-connector-java-8.0.$5/*.jar /app/$2/modules/system/layers/base/com/mysql/main/
sed -i "s/mysqlConnVer/$5/g" /vagrant/scripts/temps/module.xml
cp /vagrant/scripts/temps/module.xml /app/$2/modules/system/layers/base/com/mysql/main/module.xml
cp /vagrant/scripts/temps/standalone-ha.xml /app/$2/standalone/configuration/standalone-ha.xml

sed -i "s/mysqlIP/$1/g" /app/$2/standalone/configuration/standalone-ha.xml
sed -i "s/keycloakUserDB/$2/g" /app/$2/standalone/configuration/standalone-ha.xml
sed -i "s/keycloakPass/$3/g" /app/$2/standalone/configuration/standalone-ha.xml
chown -R $2:$2 /app 
systemctl daemon-reload && systemctl enable $2 && systemctl start $2
sleep 15
/app/$2/bin/add-user.sh --silent=true admin admin ManagementRealm
/app/$2/bin/add-user-keycloak.sh -r master -u admin -p admin

if [ "curl -s http://$4:9990/console/App.html | grep 'Management Interface' | sed -e 's/<\/title>//g;s/<title>//g'" = 'Management Interface' ]
then
    echo "The deployment was successful!"
else
    echo "Deployment was unsuccessful!"
fi
