#!/usr/bin/env bash

cat <<'EOF' > /etc/dnsmasq.d/10-consul
server=/consul/127.0.0.1#8600
EOF

declare -A keys=([consul]='1.2.3' [vault]='0.11.1')

for key in "${!keys[@]}"
do
    wget https://releases.hashicorp.com/$key/${keys[$key]}/${key}_${keys[$key]}_linux_amd64.zip
    unzip ${key}_${keys[$key]}_linux_amd64.zip -d /usr/local/bin/
    adduser -m -r -s /bin/nologin ${key}
done

mkdir /etc/{vault,consul} 
cat <<EOF > /etc/vault/vault.hcl
listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "$1:8201"
  tls_disable      = "true"
}
storage "consul" {
  address = "localhost:8500"
  path = "vault/"
  scheme = "http"
}
ui = true
disable_mlock = true
api_addr = "http://$1:8200"
cluster_addr = "http://$1:8201"
EOF

cat <<EOF > /etc/consul/client.json
{
  "server": false,
  "node_name": "$2",
  "datacenter": "dc1",
  "data_dir": "/var/consul/data",
  "bind_addr": "$1",
  "client_addr": "127.0.0.1",
  "retry_join": ["10.1.42.101", "10.1.42.102", "10.1.42.103"],
  "log_level": "DEBUG",
  "encrypt": "jY9fNFIJMB1tq3AAMhrNXQ==",
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

cat <<'EOF' > /etc/systemd/system/vault.service
### BEGIN INIT INFO
# Provides:
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: vault server
# Description:       vault secret management tool
### END INIT INFO

[Unit]
Description=Vault Secret Management Tool
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
PIDFile=/var/run/vault/vault.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/vault /var/log/vault
ExecStartPre=/bin/chown -R vault:vault /var/log/vault /var/run/vault /etc/vault
ExecStart=/bin/bash -c "/usr/local/bin/vault server -config=/etc/vault/vault.hcl -log-level=debug >> /var/log/vault/vault.log 2>&1"
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /etc/systemd/system/consul.service
### BEGIN INIT INFO
# Provides:          consul
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: consul agent
# Description:       consul service discovery framework
### END INIT INFO

[Unit]
Description=consul server agent
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
PIDFile=/var/run/consul/consul.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/consul /var/log/consul /var/consul/data
ExecStartPre=/bin/chown -R consul:consul /var/run/consul /var/log/consul /etc/consul /var/consul
ExecStart=/bin/bash -c "/usr/local/bin/consul agent -config-file=/etc/consul/client.json -enable-script-checks -pid-file=/var/run/consul/consul.pid >> /var/log/consul/consul.log 2>&1"
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

for service in consul vault dnsmasq
do
    systemctl enable $service && systemctl restart $service
done

cat <<'EOF' >> ~/.bash_profile
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_SKIP_VERIFY=true
export CONSUL_HTTP_ADDR=http://localhost:8500
export CONSUL_HTTP_SSL=false
EOF

cat <<EOF > /etc/resolv.conf
nameserver $(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }')
nameserver 8.8.8.8
EOF

#vault operator init -key-shares=3 -key-threshold=2
#vault operator unseal
#### Enter VAULT_TOKEN=ROOTTOKEN and activate approle
# curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"type": "approle"}' http://VAULT_IP:8200/v1/sys/auth/approle
