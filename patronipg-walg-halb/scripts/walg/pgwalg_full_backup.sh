#!/usr/bin/env bash

serverIP=$(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }')
patroniRole=$(curl -s -XGET http://$serverIP:8008 | jq -r .role)

if [[ $patroniRole = 'master' ]]
then
    source /etc/wal-g.d/server-s3.conf
    /usr/local/bin/wal-g backup-push $PGDATA
fi
