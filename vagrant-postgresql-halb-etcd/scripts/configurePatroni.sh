#!/usr/bin/env bash

cat <<EOF > /etc/patroni.yml
scope: postgres
namespace: /db/
name: postgresql$2

restapi:
    listen: $1$2:8008
    connect_address: $1$2:8008

etcd:
    host: $121:2379

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
                archive_command: '/bin/true'
                max_wal_senders: 8
                max_replication_slots: 8
                track_commit_timestamp: on
                hot_standby: on
                hot_standby_feedback: on
                random_page_cost: 1.2
                effective_cache_size: 2GB
                default_statistics_target: 1000
                logging_collector: on
                max_locks_per_transaction: 256
                hba_file: /etc/postgresql/10/main/pg_hba.conf
                ident_file: /etc/postgresql/10/main/pg_ident.conf

    initdb:
    - encoding: UTF8
    - data-checksums

    pg_hba:
    - host replication replicator 127.0.0.1/32 md5
    - host replication replicator $111/0 md5
    - host replication replicator $112/0 md5
    - host replication replicator $113/0 md5
    - host all all 0.0.0.0/0 md5

    users:
        admin:
            password: admin
            options:
                - createrole
                - createdb

postgresql:
    listen: $1$2:5432
    connect_address: $1$2:5432
    data_dir: /data/patroni
    pgpass: /tmp/pgpass
    authentication:
        replication:
            username: replicator
            password: reppass
        superuser:
            username: postgres
            password: secretpassword
    parameters:
        unix_socket_directories: '.'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
EOF

mkdir -p /data/patroni /var/log/patroni/ /var/run/patroni/
chown -R postgres:postgres /data/patroni /var/log/patroni/ /var/run/patroni && chmod -R 700 /data/patroni


cat <<EOF > /etc/systemd/system/patroni.service
[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Environment="PATRONI_LOGLEVEL=DEBUG"
Type=simple
User=postgres
Group=postgres
ExecStart=/bin/bash -c "/usr/local/bin/patroni /etc/patroni.yml >> /var/log/patroni/patroni.log 2>&1 & echo \$! > /var/run/patroni/patroni.pid"
PIDFile=/var/run/patroni/patroni.pid
KillMode=process
TimeoutSec=30
Restart=no

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable patroni && systemctl start patroni
