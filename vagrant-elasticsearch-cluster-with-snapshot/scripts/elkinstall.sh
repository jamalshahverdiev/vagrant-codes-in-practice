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
path.repo: ["/etc/elasticsearch/elasticsearch-backup"]
path.logs: /var/log/elasticsearch
cluster.name: elkprospect
node.name: node-master
#node.master: true
node.data: true
network.host: [_local_, "$1"]
http.port: 9200
discovery.zen.ping.unicast.hosts: ["192.168.120.40", "192.168.120.21","192.168.120.22","192.168.120.23"]
discovery.zen.minimum_master_nodes: 3
EOF

touch /etc/elasticsearch/elasticsearch.keystore
chown -R elasticsearch:elasticsearch /etc/elasticsearch/
chmod -R 750 /etc/elasticsearch/
systemctl enable elasticsearch && systemctl start elasticsearch

yum install -y kibana
cp /etc/kibana/kibana.yml /root
cat <<EOF > /etc/kibana/kibana.yml
server.host: "$1"
elasticsearch.url: ["http://$1:9200"]
EOF

systemctl enable kibana && systemctl start kibana

yum install -y logstash
echo 'export PATH=$PATH:/usr/share/logstash/bin' >> ~/.bashrc
#sudo echo 'export PATH=$PATH:/usr/share/logstash/bin' >> /etc/environment
cp /etc/logstash/logstash.yml /root/
cat <<'EOF' > /etc/logstash/logstash.yml
path.data: /var/lib/logstash
path.logs: /var/log/logstash
EOF
systemctl start logstash && systemctl enable logstash
