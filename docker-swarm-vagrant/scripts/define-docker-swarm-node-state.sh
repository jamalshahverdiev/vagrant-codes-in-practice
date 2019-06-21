#!/usr/bin/env bash

hostname=`hostname -s`
declare -a nodelist=('dockernode1' 'dockernode2' 'dockernode3' 'dockernode4')

for node in "$nodelist"
do
    if [ "$hostname" = "dockernode3" -o "$hostname" = "dockernode4" ]
    then
        echo This Swarm node configured as Worker!!!
	/vagrant/scripts/cometoworker.sh
    else
        echo This Swarm node configured as Manager!!!
        /vagrant/scripts/cometomanager.sh
    fi
done
