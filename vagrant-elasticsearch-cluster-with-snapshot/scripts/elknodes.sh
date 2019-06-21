#!/usr/bin/env bash

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat <<'EOF' > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install -y elasticsearch 
cp /etc/elasticsearch/elasticsearch.yml /root 
cat <<EOF > /etc/elasticsearch/elasticsearch.yml
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
path.repo: ["/etc/elasticsearch/elasticsearch-backup"]
cluster.name: elkprospect
node.name: elknd$1
#node.master: false
node.data: true
network.host: [_local_, "192.168.120.2$1"]
http.port: 9200
discovery.zen.ping.unicast.hosts: ["192.168.120.40", "192.168.120.21","192.168.120.22","192.168.120.23"]
discovery.zen.minimum_master_nodes: 3
EOF

touch /etc/elasticsearch/elasticsearch.keystore
chown -R elasticsearch:elasticsearch /etc/elasticsearch/
chmod -R 750 /etc/elasticsearch/
systemctl enable elasticsearch && systemctl start elasticsearch

