#!/usr/bin/env bash

patroniVersion='1.6.0-1'

yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y postgresql11 postgresql11-server
curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
tar zxf etcd-*.tar.gz && cp etcd-*linux-amd64/etcd* /usr/local/bin/
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget https://github.com/cybertec-postgresql/patroni-packaging/releases/download/$patroniVersion/patroni-$patroniVersion.rhel7.x86_64.rpm && yum install -y patroni-$patroniVersion.rhel7.x86_64.rpm

mkdir -p /db/etcd /data/pg_archived /var/log/postgresql /etc/patroni /data/patroni

cat <<EOF > /etc/patroni/patroni.yml
scope: postgres
namespace: /db/
name: $2

restapi:
    listen: $1:8008
    connect_address: $1:8008

etcd:
    host: $1:2379

bootstrap:
    dcs:
        ttl: 30
        loop_wait: 10
        retry_timeout: 10
        maximum_lag_on_failover: 1048576
        postgresql:
            use_pg_rewind: true
            parameters:
                max_connections: 500
                shared_buffers: 1GB
                huge_pages: off
                temp_buffers: 128MB
                work_mem: 16MB
                maintenance_work_mem: 256MB
                dynamic_shared_memory_type: posix
                vacuum_cost_limit: 2000
                bgwriter_delay: 20ms
                effective_io_concurrency: 2
                wal_level: logical
                checkpoint_timeout: 15min
                max_wal_size: 50GB
                min_wal_size: 1GB
                checkpoint_completion_target: 0.8
                archive_mode: on
                archive_timeout: 600s
                archive_command: "cp -f %p /data/pg_archived/%f"
                restore_command: "cp -f /data/pg_archived/%f %p"
                max_wal_senders: 8
                max_replication_slots: 8
                track_commit_timestamp: on
                hot_standby: on
                hot_standby_feedback: on
                random_page_cost: 1.2
                effective_cache_size: 2GB
                default_statistics_target: 1000
                logging_collector: on
                log_directory: "/var/log/postgresql"
                log_filename: "postgresql-11-main.log"
                max_locks_per_transaction: 256

    initdb:
    - encoding: UTF8
    - data-checksums

    pg_hba:
    - host replication replicator 127.0.0.1/32 md5
    - host replication replicator 10.1.42.141/0 md5
    - host replication replicator 10.1.42.142/0 md5
    - host replication replicator 10.1.42.143/0 md5
    - host all all 0.0.0.0/0 md5

    users:
        admin:
            password: admin
            options:
                - createrole
                - createdb

postgresql:
    listen: $1:5432
    connect_address: $1:5432
    bin_dir: /usr/pgsql-11/bin
    data_dir: /data/patroni
    pgpass: /tmp/pgpass
    authentication:
        replication:
            username: replicator
            password: Rel1c2t0rp2r0lu
        superuser:
            username: postgres
            password: P2stgre1sq1g1zl1p2r0l
    parameters:
        unix_socket_directories: '.'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
EOF

chown -R postgres:postgres /db/etcd /etc/patroni /data/pg_archived /var/log/postgresql /data/patroni

cat <<EOF > /etc/systemd/system/patroni.service
[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Environment="PATRONI_LOGLEVEL=DEBUG"
User=postgres
Group=postgres
PIDFile=/var/run/patroni/consul.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/patroni /var/log/patroni
ExecStartPre=/bin/chown -R postgres:postgres /var/run/patroni /var/log/patroni
ExecStart=/bin/bash -c "/usr/bin/patroni /etc/patroni/patroni.yml >> /var/log/patroni/patroni.log 2>&1 & echo \$! > /var/run/patroni/patroni.pid"
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/etcd.service
[Unit]
Description=etcd service
Documentation=https://github.com/etcd-io/etcd
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=postgres
ExecStart=/usr/local/bin/etcd \
  --name $2 \
  --data-dir=/db/etcd \
  --initial-advertise-peer-urls http://$1:2380 \
  --listen-peer-urls http://$1:2380 \
  --listen-client-urls http://$1:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://$1:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster pg1=http://pg1:2380,pg2=http://pg2:2380,pg3=http://pg3:2380 \
  --initial-cluster-state new

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

for service in etcd patroni 
do
    systemctl enable $service && systemctl start $service
done
