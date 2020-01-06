#!/usr/bin/env bash

yum install -y haproxy nano jq
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y postgresql11.x86_64

cat <<EOF > /etc/haproxy/haproxy.cfg
global
    maxconn 100

defaults
    log global
    mode tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s

listen stats
    mode http
    bind *:7000
    stats enable
    stats uri /

listen postgres
    bind *:5000
    option httpchk
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1_5432 10.1.42.141:5432 maxconn 100 check port 8008
    server pg2_5432 10.1.42.142:5432 maxconn 100 check port 8008
    server pg3_5432 10.1.42.143:5432 maxconn 100 check port 8008
EOF

systemctl enable haproxy && systemctl start haproxy
