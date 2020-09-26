#!/usr/bin/env bash

walGversion='v0.2.17'
wget https://github.com/wal-g/wal-g/releases/download/$walGversion/wal-g.linux-amd64.tar.gz && tar zxf wal-g.linux-amd64.tar.gz && mv wal-g /usr/local/bin/

mkdir /etc/wal-g.d/
cat <<'EOF' > /etc/wal-g.d/server-s3.conf
#!/bin/bash

export PG_VER="12.3"

export WALG_S3_PREFIX="s3://postgresql" #'postgresql' is bucket name in minio
export AWS_ACCESS_KEY_ID="pgsql_user" # access_key from minio
export AWS_ENDPOINT="http://10.1.42.225:9001" # Minio server and port
export AWS_S3_FORCE_PATH_STYLE="true"
export AWS_SECRET_ACCESS_KEY="pgsqluserf0rM1ni0" # SecretKey from minio

export PGDATA=/data/patroni/  # Data path from patroni
export PGHOST=/var/run/postgresql/.s.PGSQL.5432 # Socket file path from PostgreSQL which is defined in patroni

export WALG_UPLOAD_CONCURRENCY=2 # Thread count to upload
export WALG_DOWNLOAD_CONCURRENCY=2 # Thread count to download
export WALG_UPLOAD_DISK_CONCURRENCY=2 # Thread count to write to the disk
export WALG_DELTA_MAX_STEPS=7
export WALG_COMPRESSION_METHOD=brotli # Compression method to use
EOF

cp /vagrant/scripts/walg/* /usr/local/bin
chmod +x /usr/local/bin/* /etc/wal-g.d/server-s3.conf

# etcdctl member list
# etcdctl ls --recursive --sort -p /db
# ETCDCTL_API=2 etcdctl rm /db --recursive
