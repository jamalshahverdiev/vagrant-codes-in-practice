#!/usr/bin/env bash

yum install -y haproxy nano jq
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y postgresql12.x86_64

cat <<EOF > /etc/haproxy/haproxy.cfg
global
    log 127.0.0.1:514 local0
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    daemon
    nbproc 3
    cpu-map auto:1-4 0-3
    maxconn 100000

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
    stats auth admin:admin
    stats refresh 10s
    stats show-legends

listen master_postgres
    bind *:5432
    option httpchk
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1_5432 10.1.42.141:5432 maxconn 100 check port 8008
    server pg2_5432 10.1.42.142:5432 maxconn 100 check port 8008
    server pg3_5432 10.1.42.143:5432 maxconn 100 check port 8008

listen slaves_postgres
    bind *:5433
    option httpchk
    http-check expect status 503
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1_5432 10.1.42.141:5432 maxconn 100 check port 8008
    server pg2_5432 10.1.42.142:5432 maxconn 100 check port 8008
    server pg3_5432 10.1.42.143:5432 maxconn 100 check port 8008
EOF

systemctl enable haproxy && systemctl start haproxy
sleep 3
PGPASSWORD=$2 psql -h $1 -p 5000 -c "CREATE DATABASE appdb;" -U postgres
PGPASSWORD=$2 psql -h $1 -p 5000 -c "CREATE USER appuser WITH PASSWORD 'Appp244f0rD2t2b2s1d1r';" -U postgres
PGPASSWORD=$2 psql -h $1 -p 5000 -c "GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;" -U postgres
PGPASSWORD=$2 psql -h $1 -p 5000 -c "ALTER USER appuser WITH SUPERUSER;" -U postgres
