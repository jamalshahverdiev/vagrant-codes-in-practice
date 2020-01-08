#!/usr/bin/env bash

consulIP=$(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }')

cat <<EOF > webserver.json
{
  "name": "webserver",
  "tags": ["webserver"],
  "port": 80,
  "check": {
    "id": "webserver_up",
    "name": "Fetch index page from remote Nginx",
    "http": "http://${consulIP}/index.html",
    "interval": "3s",
    "timeout": "1s"
  }
}
EOF

curl -s -XPUT -d @webserver.json http://${consulIP}:8500/v1/agent/service/register
