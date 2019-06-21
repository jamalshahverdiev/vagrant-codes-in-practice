#!/usr/bin/env bash

services="$1 $2"
loginPass="vagrant"

copyCert() {
   sudo cp /vagrant/rootCA.crt /etc/pki/ca-trust/source/anchors/
   sudo update-ca-trust extract
   sudo cp /vagrant/rootCA.{crt,pem} /vagrant/$1.{key,crt} /etc/$1/
   sudo chown -R $1:$1 /etc/$1
}

if [ "$(hostname)" = "consuls1" ]
then
    openssl genrsa -out /vagrant/rootCA.key 2048
    openssl req -x509 -new -key /vagrant/rootCA.key -days 10000 -out /vagrant/rootCA.crt -subj "/C=BY/ST=Minsk/L=Minsk/O=EPAM/OU=Devops/CN=ca.epam.com"
    openssl x509 -in /vagrant/rootCA.crt -out /vagrant/rootCA.pem -outform PEM

    for service in $services
    do
        openssl genrsa -out /vagrant/$service.key 2048
        openssl req -new -key /vagrant/$service.key -out /vagrant/$service.csr -subj "/C=BY/ST=Minsk/L=Minsk/O=EPAM/OU=Devops/CN=$service.epam.com"
        openssl x509 -req -in /vagrant/$service.csr -CA /vagrant/rootCA.crt -CAkey /vagrant/rootCA.key -CAcreateserial -out /vagrant/$service.crt -days 5000
    done
    copyCert $1
else
    sshpass -p $3 scp -oStrictHostKeyChecking=no -r $3@10.1.42.101:/$3/* /$3/
    copyCert $1
fi 
