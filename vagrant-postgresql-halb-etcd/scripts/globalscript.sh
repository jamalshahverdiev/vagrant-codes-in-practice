#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
apt update -y && apt dist-upgrade -y
apt remove -y iptables

if [ $(hostname) = halb ]
then
    apt install haproxy -y
elif [ $(hostname) = etcd ]
then
    apt install etcd -y
elif [ $(hostname) = $1 ]
then
    apt install postgresql-10 -y
    #sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
    #wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
    #apt update
    #apt install -y postgresql-contrib-9.6 postgresql-9.6 libpq-dev pgadmin3 
    ln -s /usr/lib/postgresql/10/bin/* /usr/sbin/
    apt install python python-pip python-psycopg2 -y
    pip install --upgrade setuptools
    pip install patroni[etcd,aws,consul,zookeeper]
fi

