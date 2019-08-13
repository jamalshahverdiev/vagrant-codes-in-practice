#!/usr/bin/env bash

if [ $# -lt 2 ]
then
    echo "Usage: $0 domainName vertoUserPass"
    exit 102
fi

curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get update && apt-get -y install nodejs

git clone -b v1.8  https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch
cd /usr/src/freeswitch/html5/verto/verto_communicator
npm install -g grunt grunt-cli bower
npm install
bower --allow-root install
grunt build

cp -r /usr/src/freeswitch/html5/verto/verto_communicator/dist/* /var/www/public_html/$1/
sed -i "s/1234/$2/" /var/www/public_html/$1/config.json
