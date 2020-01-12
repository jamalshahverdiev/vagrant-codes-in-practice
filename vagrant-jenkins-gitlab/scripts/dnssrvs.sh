#!/usr/bin/env bash

yum install -y bind bind-utils

yes | cp -rf /vagrant/scripts/named.conf /etc/named.conf
sed -i "s/changeme/$1/g" /etc/named.conf

if [ "$(hostname)" = "dns1" ]
then
cat <<EOF >> /etc/named.conf 
zone "prospectsmb.com" IN {
        type master;
        file "/var/named/forward.prospectsmb.com";
        allow-update { none; };
};
EOF
wget https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.tgz && tar -zxf consul-template_0.19.5_linux_amd64.tgz -C /usr/local/bin/
cat <<'EOF' >> /etc/systemd/system/consul-dns-template.service
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
User=root
Group=root
PIDFile=/var/run/consul-template/template.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/consul-template /var/log/consul-template
#ExecStartPre=/bin/chown -R consul:consul /var/run/consul-template
ExecStart=/bin/bash -c "/usr/local/bin/consul-template -template '/etc/consul-template.d/nginx-vhost-weight.conf.ctmpl:/etc/nginx/conf.d/appandcore.conf:nginx -s reload' -pid-file=/var/run/consul-template/template.pid >> /var/log/consul-template/consul.log 2>&1"
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF
cp /vagrant/scripts/forward.prospectsmb.com /var/named/forward.prospectsmb.com
systemctl daemon-reload
for service in named consul-dns-template
do
    systemctl enable $service && systemctl restart $service
done
fi

if [ "$(hostname)" = "dns2" ]
then
cat <<EOF >> /etc/named.conf
zone "prospectsmb.com" IN {
        type slave;
        file "slaves/forward.prospectsmb.com";
        masters { 10.1.42.161; };
};
EOF
systemctl enable named && systemctl restart named
fi


