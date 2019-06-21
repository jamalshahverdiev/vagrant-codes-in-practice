#!/usr/bin/env bash

if [ ! -x "/vagrant/scripts/jointocluster.sh" ]
then 
      chmod +x /vagrant/scripts/jointocluster.sh
      chown vagrant:vagrant /vagrant/scripts/jointocluster.sh
fi

runuser -l vagrant -c '/vagrant/scripts/jointocluster.sh'
