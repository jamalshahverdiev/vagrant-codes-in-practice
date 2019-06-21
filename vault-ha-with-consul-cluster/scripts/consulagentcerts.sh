#!/usr/bin/env bash

services="$1 $2"
hosts="101 102 201 202"
sshpass -p $3 scp -oStrictHostKeyChecking=no -r $3@10.1.42.101:/$3/* /$3/
sudo cp /$3/rootCA.{crt,pem} /$3/$1.{crt,key} /etc/$2/
sudo cp /$3/rootCA.{crt,pem} /$3/$2.{crt,key} /etc/$2/
sudo cp /$3/rootCA.{crt,pem} /$3/$1.{crt,key} /etc/$1/

for service in $services
do
    sudo chown -R $service:$service /etc/$service
done
   
sudo cp /vagrant/rootCA.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract

