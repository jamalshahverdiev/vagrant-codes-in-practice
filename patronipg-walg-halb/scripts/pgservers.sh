#!/usr/bin/env bash

patroniVersion='1.6.5-1'
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y postgresql12 postgresql12-server postgresql12-contrib hypopg_12.x86_64 pg_qualstats12 pgfincore12.x86_64
curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
tar zxf etcd-*.tar.gz && cp etcd-*linux-amd64/etcd* /usr/local/bin/
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget https://github.com/cybertec-postgresql/patroni-packaging/releases/download/$patroniVersion/patroni-$patroniVersion.rhel7.x86_64.rpm && yum install -y patroni-$patroniVersion.rhel7.x86_64.rpm

## CREATE EXTENSION hypopg WITH SCHEMA myextensions;
mkdir -p  /db/etcd /data/{patroni,pg_archived} /var/log/postgresql /etc/{etcd,patroni}

cat <<EOF > /etc/patroni/patroni.yml
scope: patpgwalg
namespace: /patpg/
name: $2

restapi:
    listen: $1:8008
    connect_address: $1:8008

etcd:
    hosts: ["10.1.42.141:2379", "10.1.42.142:2379", "10.1.42.143:2379"]

bootstrap:
    dcs:
        ttl: 30
        loop_wait: 10
        retry_timeout: 10
        maximum_lag_on_failover: 1048576
        postgresql:
            use_pg_rewind: true
            parameters:
                max_connections: 40
                shared_buffers: 1GB
                huge_pages: off
                temp_buffers: 128MB
                work_mem: 16MB
                maintenance_work_mem: 768MB
                dynamic_shared_memory_type: posix
                vacuum_cost_limit: 2000
                bgwriter_delay: 20ms
                effective_io_concurrency: 300
                wal_level: replica
                wal_buffers: 16MB
                checkpoint_timeout: 15min
                max_wal_size: 8GB
                min_wal_size: 2GB
                checkpoint_completion_target: 0.9
                archive_mode: on
                archive_timeout: 60
                archive_command: "/usr/local/bin/wal-push.sh %p"
                restore_command: "/usr/local/bin/wal-fetch.sh %f %p"
                autovacuum_analyze_scale_factor: 0.1
                autovacuum_analyze_threshold: 50
                autovacuum_max_workers: 3
                autovacuum_naptime: 60s
                autovacuum_vacuum_scale_factor: 0.2
                autovacuum_vacuum_threshold: 50
                max_wal_senders: 8
                max_replication_slots: 8
                track_commit_timestamp: on
                hot_standby: on
                hot_standby_feedback: on
                random_page_cost: 1.1
                effective_cache_size: 2GB
                default_statistics_target: 100
                log_checkpoints: 'on'
                log_connections: 'on'
                log_disconnections: 'on'
                log_duration: 'on'
                log_filename: postgresql-%a.log
                log_line_prefix: '%m - %l - %p - %h - %u@%d - %x'
                log_lock_waits: 'on'
                log_min_duration_statement: 1000
                log_min_error_statement: NOTICE
                log_min_messages: WARNING
                log_rotation_age: '1440'
                log_timezone: Asia/Baku
                log_truncate_on_rotation: on
                logging_collector: on
                log_directory: "/var/log/postgresql"
                max_locks_per_transaction: 256
                max_worker_processes: 8
                max_parallel_workers_per_gather: 4
                max_parallel_maintenance_workers: 4
                max_parallel_workers: 8
                pg_qualstats.enabled: true
                pg_qualstats.max: 2000
                pg_qualstats.track_constants: true
                track_activity_query_size: 32768
                log_min_duration_statement: 5000
                session_preload_libraries: auto_explain
                shared_preload_libraries: pg_stat_statements, pg_qualstats

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
    bin_dir: /usr/pgsql-12/bin
    data_dir: /data/patroni
    pgpass: /tmp/pgpass
    authentication:
        replication:
            username: replicator
            password: Rel1c2t0rp2r0lu
        superuser:
            username: postgres
            password: $3
    parameters:
        unix_socket_directories: '/var/run/postgresql'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
EOF

cat <<EOF > /etc/etcd/etcd.conf
name: $2
enable-v2: true
data-dir: /db/etcd
initial-advertise-peer-urls: http://$1:2380
listen-peer-urls: http://$1:2380
listen-client-urls: http://$1:2379,http://127.0.0.1:2379
advertise-client-urls: http://$1:2379
initial-cluster: "patpg1=http://patpg1:2380,patpg2=http://patpg2:2380,patpg3=http://patpg3:2380"
EOF


chown -R postgres:postgres /db/etcd /data/{patroni,pg_archived} /var/log/postgresql /etc/{etcd,patroni} /etc/wal-g.d /usr/local/bin

cat <<EOF > /etc/systemd/system/patroni.service
[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Environment="PATRONI_LOGLEVEL=DEBUG"
User=postgres
Group=postgres
LimitNOFILE=infinity
LimitNPROC=infinity
LimitAS=infinity
LimitFSIZE=infinity
PIDFile=/var/run/patroni/patroni.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/patroni /var/log/patroni
ExecStartPre=/bin/chown -R postgres:postgres /var/run/patroni /var/log/patroni
ExecStart=/bin/bash -c "/usr/bin/patroni /etc/patroni/patroni.yml >> /var/log/patroni/patroni.log 2>&1 & echo \$! > /var/run/patroni/patroni.pid"
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /etc/systemd/system/etcd.service
[Unit]
Description=etcd service
Documentation=https://github.com/etcd-io/etcd
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=postgres
Group=postgres
ExecStartPre=-/bin/mkdir -p /var/run/etcd
ExecStartPre=/bin/chown -R postgres:postgres /var/run/etcd
LimitNOFILE=infinity
LimitNPROC=infinity
LimitAS=infinity
LimitFSIZE=infinity
PIDFile=/var/run/etcd/etcd.pid
PermissionsStartOnly=true
ExecStart=/bin/bash -c "/usr/local/bin/etcd --config-file /etc/etcd/etcd.conf >> /var/log/postgresql/etcd.log 2>&1 & echo $! > /var/run/etcd/etcd.pid"
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=30s

[Install]
WantedBy=multi-user.target
EOF

chmod -R 700 /data/patroni /db/etcd
chmod +x /usr/local/bin/*

systemctl daemon-reload

for service in etcd patroni 
do
    systemctl enable $service && systemctl start $service
done

# etcdctl member list
# etcdctl ls --recursive --sort -p /db
# ETCDCTL_API=2 etcdctl rm /db --recursive
