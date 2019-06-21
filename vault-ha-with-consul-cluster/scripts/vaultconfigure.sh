#!/usr/bin/env bash

wget https://releases.hashicorp.com/vault/0.11.1/vault_0.11.1_linux_amd64.zip
sudo unzip $2_0.11.1_linux_amd64.zip -d /usr/local/bin/
sudo mkdir -p /var/log/$2 /var/run/$2

sudo cat <<EOF > /etc/$2/$2_server.hcl
listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "$1:8201"
  tls_disable      = "false"
  tls_cert_file = "/etc/$2/$2.crt"
  tls_key_file = "/etc/$2/$2.key"
}

storage "consul" {
  address = "$3:8500"
  path = "$2/"
  scheme = "https"
  tls_skip_verify = 0
  tls_key_file = "/etc/$2/consul.key"
  tls_cert_file = "/etc/$2/consul.crt"
  tls_ca_file = "/etc/$2/rootCA.pem"  
}
ui = true
disable_mlock = true
api_addr = "https://$1:8200"
cluster_addr = "https://$1:8201"
EOF

sudo cat <<EOF > /etc/systemd/system/$2.service
### BEGIN INIT INFO
# Provides:          $2
# Required-Start:    \$local_fs \$remote_fs
# Required-Stop:     \$local_fs \$remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: $2 server
# Description:       $2 secret management tool
### END INIT INFO

[Unit]
Description=$2 secret management tool
Requires=network-online.target
After=network-online.target

[Service]
User=$2
Group=$2
PIDFile=/var/run/$2/$2.pid
ExecStart=/bin/bash -c "/usr/local/bin/$2 server -config=/etc/$2/$2_server.hcl -log-level=debug >> /var/log/$2/$2.log 2>&1"
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo chown -R $2:$2 /usr/local/bin/$2 /var/log/$2 /etc/$2 /var/run/$2
sudo systemctl start $2.service && sudo systemctl enable $2.service
#echo "export VAULT_ADDR='http://127.0.0.1:8200'" >> ~/.bash_profile
echo 'export CONSUL_HTTP_SSL=true' >> ~/.bash_profile
echo 'export CONSUL_HTTP_ADDR=https://$(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }'):8500' >> ~/.bash_profile
echo "export CONSUL_CACERT=/etc/$2/rootCA.crt" >> ~/.bash_profile
echo "export CONSUL_CAPATH=/etc/$2/" >> ~/.bash_profile
echo "export CONSUL_CLIENT_CERT=/etc/$2/consul.crt" >> ~/.bash_profile
echo "export CONSUL_CLIENT_KEY=/etc/$2/consul.key" >> ~/.bash_profile
echo "export CONSUL_TLS_SERVER_NAME=$3" >> ~/.bash_profile
echo "export VAULT_SKIP_VERIFY=true" >> ~/.bash_profile

sudo echo "127.0.0.1 $3" >> /etc/hosts
#sudo /usr/local/bin/consul members -http-addr=https://$3:8500 >> /root/output.txt
# To check vault status use this command: vault status --tls-skip-verify
