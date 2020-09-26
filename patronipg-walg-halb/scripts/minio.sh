#!/usr/bin/env bash

#wget https://dl.min.io/server/minio/release/linux-amd64/minio && chmod +x minio && mv minio /usr/sbin/
pushd /vagrant/scripts
tar jxf minio.tar.bz2 && chmod +x minio && mv minio /usr/sbin/
popd

adminUser='superadmin'
adminPass='SUkhrlik_o87y4uijrf98as'
serverIP=$1

cat <<EOF > /etc/systemd/system/minio.service
[Unit]
Description=MinIO storage object API
After=network.target

[Service]
Environment="MINIO_ACCESS_KEY=$adminUser"
Environment="MINIO_SECRET_KEY=$adminPass"
User=root
Group=root
PIDFile=/var/run/minio/minio.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/minio /var/log/minio /opt/miniodata{1,2}
ExecStart=/bin/bash -c "/usr/sbin/minio server --address $serverIP:9001 http://minio0{1...4}/opt/miniodata{1...2} >> /var/log/minio/minio.log 2>&1 & echo \$! > /var/run/minio/minio.pid"
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitAS=infinity
LimitFSIZE=infinity
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.42.171 minio01
10.1.42.172 minio02
10.1.42.173 minio03
10.1.42.174 minio04
EOF

systemctl enable minio --now
export MINIO_ACCESS_KEY=$adminUser
export MINIO_SECRET_KEY=

if [[ $(hostname) = minio4 ]]
then
    pushd /vagrant/scripts
    tar jxf mc.tar.bz2 && chmod +x mc && mv mc /usr/sbin/
    popd
    #wget https://dl.min.io/client/mc/release/linux-amd64/mc && chmod +x mc && mv mc /usr/sbin/
    mc config host add minio http://$serverIP:9001 $adminUser $adminPass --api s3v4
cat <<'EOF' > postgresql.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::postgresql"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::postgresql/*"]
    }
  ]
}
EOF
    mc admin policy add minio pgsql_policy postgresql.json --debug
    mc admin user add minio pgsql_user pgsqluserf0rM1ni0
    mc admin policy set minio pgsql_policy user=pgsql_user
    mc admin group add minio pgsql_grp pgsql_user
    mc mb minio/postgresql
fi
