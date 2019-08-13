#!/usr/bin/env bash

if [ $# -lt 4 ]
then
    echo "Usage: $0 subnet dbUser dbPass dbName"
    exit 100
fi 

echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt update
apt install -y postgresql-10
ipAddr=$(ifconfig eth1 | grep 'inet ' | awk '{ print $2 }')
sed -i 's/max_connections = 100/max_connections = 1000/g' /etc/postgresql/10/main/postgresql.conf 
echo "listen_addresses = '"$ipAddr"'" >> /etc/postgresql/10/main/postgresql.conf

for range in $(seq 2) 00
do
   echo "host    $4          $2            $11$range/32                md5" >> /etc/postgresql/10/main/pg_hba.conf
done

su - postgres -c "psql -c \"CREATE DATABASE $4;\""
su - postgres -c "psql -c \"CREATE USER $2 WITH PASSWORD '$3';\""
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $4 TO $2;\""

echo 'kernel.shmmax = 18446744073692774399' >> /etc/sysctl.conf && sysctl -p
systemctl restart postgresql && systemctl enable postgresql
