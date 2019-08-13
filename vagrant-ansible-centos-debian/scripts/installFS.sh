#!/usr/bin/env bash

if [ $# -lt 4 ]
then
    echo "Usage: $0 pgIP dbUser dbPass dbName"
    exit 100
fi

apt install net-tools -y
wget -O - https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc | apt-key add -
echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" >> /etc/apt/sources.list.d/freeswitch.list
apt-get update
apt install -y freeswitch-meta-all freeswitch-mod-v8
apt install -y unixodbc odbc-postgresql

cat <<EOF > /etc/odbc.ini
[$4]
Driver = PostgreSQL Unicode
Description = FSPgSQL
Servername = $1
Port = 5432
Protocol = 10
UserName = $2
Password = $3
Database = $4
EOF

echo | isql fsdb
if [ $? -ne 0 ]
then
    echo "ODBC configuration failed!!!"
    exit 101
fi

