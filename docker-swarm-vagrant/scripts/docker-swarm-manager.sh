#!/usr/bin/env bash

docker swarm init --advertise-addr enp0s8
dockermaster=$(docker swarm join-token manager | grep docker | sed 's/    //g')
dockerworker=$(docker swarm join-token worker | grep docker | sed 's/    //g')

echo $dockermaster > /vagrant/scripts/cometomanager.sh
echo $dockerworker > /vagrant/scripts/cometoworker.sh

chmod +x /vagrant/scripts/cometomanager.sh /vagrant/scripts/cometoworker.sh
