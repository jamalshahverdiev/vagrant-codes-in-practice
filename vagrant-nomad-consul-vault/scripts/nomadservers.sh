#!/usr/bin/env bash

wget https://releases.hashicorp.com/nomad/$3/nomad_$3_linux_amd64.zip
unzip nomad_$3_linux_amd64.zip -d /usr/bin/

mkdir -p /etc/$2 /nomad-data /var/log/$2 /var/run/$2 

if [ "$(hostname)" = "nomadconsulsrv1" -o "$(hostname)" = "nomadconsulsrv2" -o "$(hostname)" = "nomadconsulsrv3" ]
then
cat <<EOF > /etc/$2/config.hcl
data_dir = "/nomad-data"
bind_addr = "$1"
region = "global"
log_level = "DEBUG"

acl {
  enabled = false
}

client {
  enabled = true
  network_interface = "eth1"
  options {
    "driver.raw_exec.enable" = "1"
    "driver.exec.enable" = "1"
  }
}

server {
  enabled          = true
  bootstrap_expect = 3

  server_join {
    retry_join = ["10.1.42.101:4648", "10.1.42.102:4648", "10.1.42.103:4648"]
  }
}
EOF
else
cat <<EOF > /etc/$2/config.hcl
# Increase log verbosity for testing/debugging
log_level = "DEBUG"

# Specify the Nomad client data directory
data_dir = "/nomad-data"
bind_addr = "$1"
#advertise {
#    http = "$1"
#    rpc  = "$1"
#    serf = "$1"
#}
# Set Nomad to client mode
client {
    enabled = true
    servers = ["10.1.42.101:4647", "10.1.42.102:4647", "10.1.42.103:4647"]
    network_interface = "eth1"
    options {
      "driver.raw_exec.enable" = "1"
      "driver.exec.enable" = "1"
    }
}
EOF
fi

cat <<EOF > /etc/systemd/system/$2.service
### BEGIN INIT INFO
# Provides:          $2
# Required-Start:    \$local_fs \$remote_fs
# Required-Stop:     \$local_fs \$remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: $2 agent
# Description:       $2 microservice controller
### END INIT INFO

[Unit]
Description=$2 server agent
Requires=network-online.target
After=network-online.target

[Service]
User=root
Group=root
PIDFile=/var/run/$2/$2.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/$2
ExecStartPre=/bin/chown -R root:root /var/run/$2
ExecStart=/bin/bash -c "/usr/bin/$2 agent -config /etc/$2/config.hcl 2>&1 >> /var/log/$2/$2.log & echo \$! > /var/run/$2/$2.pid"
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

echo "export NOMAD_ADDR=http://$1:4646" >> ~/.bash_profile
chown -R root:root /usr/bin/$2 /etc/$2 /nomad-data /var/log/$2 /etc/$2 /var/run/$2
systemctl start $2.service && systemctl enable $2.service

if [ "$(hostname)" = "nomadconsulagent2" ]
then
    #nomad server members
    #nomad node status
    #nomad job status
    #nomad job status example
    #allocID=$(nomad job status example | tail -n 1 | awk '{ print $1 }')
    #nomad alloc status $allocID
    #nomad alloc-status -short $allocID
    
    #nomad job init
    #nomad job validate example.nomad
    #dockerRedisEval=$(nomad plan example.nomad | grep 'example.nomad') && $dockerRedisEval
    sleep 5
    export NOMAD_ADDR=http://$1:4646
    nomad job validate /vagrant/jobs/dockerApp.nomad
    dockerAppEval=$(nomad plan /vagrant/jobs/dockerApp.nomad | grep 'dockerApp.nomad') && $dockerAppEval
    
    nomad job validate /vagrant/jobs/javaApp.nomad
    javaAppEval=$(nomad plan /vagrant/jobs/javaApp.nomad | grep 'javaApp.nomad') && $javaAppEval
    
    nomad job validate /vagrant/jobs/pythonApp.nomad
    pythonAppEval=$(nomad plan /vagrant/jobs/pythonApp.nomad | grep 'pythonApp.nomad') && $pythonAppEval
    #
    #nomad job stop -purge python-app
    #nomad job stop -purge java-app
    #nomad job deployments api-v3
    #nomad deployment list
    #nomad deployment status 2cf8ff7f
    ################# ALLOCATION ###############
    #nomad alloc fs -verbose 2dca2684 pythonApp/local/
    #nomad alloc status 2dca2684
    #nomad alloc status -verbose 02cfbef5
    #nomad alloc logs 62e6f3dd
    #nomad alloc logs -tail -f 36161b84
fi
