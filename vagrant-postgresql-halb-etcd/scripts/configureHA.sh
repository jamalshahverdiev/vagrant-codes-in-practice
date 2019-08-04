#!/usr/bin/env bash

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
    server postgresql_$111_5432 $111:5432 maxconn 100 check port 8008
    server postgresql_$112_5432 $112:5432 maxconn 100 check port 8008
    server postgresql_$113_5432 $113:5432 maxconn 100 check port 8008
EOF

systemctl restart haproxy && systemctl enable haproxy
