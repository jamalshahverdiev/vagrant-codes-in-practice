#!/usr/bin/env bash

wget https://releases.hashicorp.com/$2/1.2.3/$2_1.2.3_linux_amd64.zip
sudo unzip $2_1.2.3_linux_amd64.zip -d /usr/local/bin/
sudo mkdir -p /var/$2/data /var/log/$2 /var/run/$2

string=$1
sudo cat <<EOF > /etc/$2/server_agent.json
{
  "server": true,
  "node_name": "$2_s${string:10:10}",
  "datacenter": "dc1",
  "data_dir": "/var/$2/data",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$1",
  "bootstrap_expect": 3,
  "encrypt": "jY9fNFIJMB1tq3AAMhrNXQ==",
  "retry_join": ["10.1.42.101", "10.1.42.102", "10.1.42.103"],
  "ui": true,
  "log_level": "DEBUG",
  "enable_syslog": true,
  "acl_enforce_version_8": false,
  "dns_config": {
    "allow_stale": true,
    "max_stale": "2s",
    "node_ttl": "30s",
    "service_ttl": {
      "*": "10s"
    },
    "a_record_limit": 1,
    "enable_truncate": false,
    "only_passing": false
  },

  "enable_debug": true,
  "addresses": {
    "http": "0.0.0.0"
  },
  "verify_incoming": false,
  "verify_outgoing": false
}
EOF

sudo cat <<EOF > /etc/systemd/system/$2.service
### BEGIN INIT INFO
# Provides:          $2
# Required-Start:    \$local_fs \$remote_fs
# Required-Stop:     \$local_fs \$remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: $2 agent
# Description:       $2 service discovery framework
### END INIT INFO

[Unit]
Description=$2 server agent
Requires=network-online.target
After=network-online.target

[Service]
User=$2
Group=$2
PIDFile=/var/run/$2/$2.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/$2
ExecStartPre=/bin/chown -R $2:$2 /var/run/$2
ExecStart=/bin/bash -c "/usr/local/bin/$2 agent -config-file=/etc/$2/server_agent.json -enable-script-checks -pid-file=/var/run/$2/$2.pid >> /var/log/$2/$2.log 2>&1"
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

chown -R $2:$2 /usr/local/bin/$2 /var/$2/data /var/log/$2 /etc/$2 /var/run/$2
systemctl start $2.service && systemctl enable $2.service
