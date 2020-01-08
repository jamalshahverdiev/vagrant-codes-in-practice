#!/usr/bin/env bash

rpm --import https://packages.erlang-solutions.com/rpm/erlang_solutions.asc
#yum -y remove $(rpm -qa|grep erlang)

cat <<'EOF' > /etc/yum.repos.d/erlang.repo
[erlang-solutions]
name=CentOS $releasever - $basearch - Erlang Solutions
baseurl=https://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch
gpgcheck=1
gpgkey=https://packages.erlang-solutions.com/rpm/erlang_solutions.asc
enabled=1
EOF

rpm --import https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
yum update -y

yum install -y erlang

cat <<EOF > /etc/yum.repos.d/rabbitmq.repo
[bintray-rabbitmq-server]
name=bintray-rabbitmq-rpm
baseurl=https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/v3.7.x/el/7/
gpgcheck=0
repo_gpgcheck=0
enabled=1
EOF

yum -y install rabbitmq-server.noarch

systemctl start rabbitmq-server.service && systemctl enable rabbitmq-server.service
sleep 2
#rabbitmqctl status
rabbitmqctl add_user mqadmin UHkjdnedm_io8u3e23kdjsoda
rabbitmqctl set_user_tags mqadmin administrator
rabbitmqctl set_permissions -p / mqadmin ".*" ".*" ".*"
