#!/bin/bash
# see https://gogs.io/docs/installation/install_from_source
# see https://gogs.io/docs/advanced/configuration_for_source_builds
# see https://github.com/gogits/gogs/blob/develop/docker/build.sh
# see https://github.com/gogits/gogs/blob/develop/conf/app.ini
set -eux

domain=git.example.com
testing=true

# refresh package cache.
apt-get update

# install postgres.
apt-get install -y --no-install-recommends build-essential git postgresql

# configure postgres to allow the host (pgAdmin III) to easily connect. 
if $testing; then
    echo 'host all all 192.168.33.0/24 trust' >> /etc/postgresql/*/main/pg_hba.conf
    pg_conftool set listen_addresses '*'
    apt-get install -y --no-install-recommends postgresql-contrib
    systemctl restart postgresql
    sudo -sHu postgres psql -c 'create extension adminpack'
    sudo -sHu postgres psql -c 'select * from pg_extension'
fi

# create user and database.
sudo -sHu postgres psql -c 'create role git login'
sudo -sHu postgres createdb -E UTF8 -O git gogs

# show version, users and databases.
sudo -sHu postgres psql -c 'select version()'
sudo -sHu postgres psql -c '\du'
sudo -sHu postgres psql -l

# create the `git` user and group.
groupadd --system --gid 990 git
# NB As long as we dont set a password (keep it locked) on the git account
#    there is no need to also setup git-shell, as Gogs refuses non-git
#    commands.
# NB Gogs manages `~/.ssh/authorized_keys`.
useradd --system --uid 990 -g git -m git
# just to be sure, disable the password login.
usermod --lock git
chmod 750 /home/git
install -d -o git -g root -m 750 /home/git/gogs-repositories

build-gogs (){
    export GOPATH=$PWD/gopath
    export PATH=$GOPATH/bin:$PATH
    if [ ! -d $GOPATH/src/github.com/gogits/gogs ]
    then
        mkdir -p $GOPATH/{src,pkg,bin}
        git clone -b v0.11.29 https://github.com/gogits/gogs $GOPATH/src/github.com/gogits/gogs
        sed -i -E 's/(\s+)(cmd.Admin,)/\1\2\n\1cmd.CreateAdminUser,/' $GOPATH/src/github.com/gogits/gogs/gogs.go
        ln -s /vagrant/scripts-tepms/temps/create-admin-user.go $GOPATH/src/github.com/gogits/gogs/cmd/
    fi
    if [ ! -f $GOPATH/bin/go-bindata ]
    then
        go get -v github.com/jteeuwen/go-bindata/...
    fi
    pushd $GOPATH/src/github.com/gogits/gogs
    go env
    make build
    popd
}

# build and install gogs from source.
apt-get install -y --no-install-recommends software-properties-common
add-apt-repository ppa:gophers/archive
apt-get update
apt-get install -y --no-install-recommends golang-1.9-go node-less
echo 'export PATH="$PATH:/usr/lib/go-1.9/bin"' >/etc/profile.d/golang.sh
source /etc/profile.d/golang.sh
build-gogs
install -o root -g git -m 755 -d /opt/gogs
cp gopath/bin/gogs /opt/gogs/
cp -R gopath/src/github.com/gogits/gogs/{templates,public} /opt/gogs/
install -o root -g git -m 770 -d /opt/gogs/data
install -o root -g git -m 770 -d /opt/gogs/log
install -o root -g git -m 640 /vagrant/scripts-tepms/temps/app.ini /opt/gogs/
# configure gogs.
sed -i -E "s,(DOMAIN\s+=).+,\1 $domain,g" /opt/gogs/app.ini
sed -i -E "s,(ROOT_URL\s+=).+,\1 https://$domain/,g" /opt/gogs/app.ini
sed -i -E "s,(SECRET_KEY\s+=).+,\1 $(openssl rand -base64 24),g" /opt/gogs/app.ini
# install the gogs systemd service unit and start gogs.
install /vagrant/scripts-tepms/temps/gogs.service /etc/systemd/system/
systemctl enable gogs
systemctl start gogs

# wait for the database initialization to finish (by waiting for gogs to be ready). 
while true; do
    wget --quiet -qO- http://127.0.0.1:3000/explore/repos >/dev/null && break || sleep 1
done

# create the gogs administrator account.
apiKey=$(sudo -sHu git /opt/gogs/gogs \
    create-admin-user \
    --config /opt/gogs/app.ini \
    --name gogs \
    --email 'gogs@local' \
    --password gogspassword) 

# create a self-signed certificate.
pushd /etc/ssl/private
openssl genrsa \
    -out $domain-keypair.pem \
    2048 \
    2>/dev/null
chmod 400 $domain-keypair.pem
openssl req -new \
    -sha256 \
    -subj "/CN=$domain" \
    -key $domain-keypair.pem \
    -out $domain-csr.pem
openssl x509 -req -sha256 \
    -signkey $domain-keypair.pem \
    -extensions a \
    -extfile <(echo "[a]
        subjectAltName=DNS:$domain
        extendedKeyUsage=serverAuth
        ") \
    -days 365 \
    -in  $domain-csr.pem \
    -out $domain-crt.pem
popd

# setup nginx proxy to localhost:3000.
apt-get install -y --no-install-recommends nginx
cat<<EOF>/etc/nginx/sites-available/gogs
ssl_session_cache shared:SSL:4m;
ssl_session_timeout 6h;
#ssl_stapling on;
#ssl_stapling_verify on;

server {
    listen 80;
    server_name _;
    return 301 https://$domain\$request_uri?;
}

server {
    listen 443 ssl http2;
    server_name $domain;
    ssl_certificate /etc/ssl/private/$domain-crt.pem;
    ssl_certificate_key /etc/ssl/private/$domain-keypair.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    # see https://github.com/cloudflare/sslconfig/blob/master/conf
    # see https://blog.cloudflare.com/it-takes-two-to-chacha-poly/
    # see https://blog.cloudflare.com/do-the-chacha-better-mobile-performance-with-cryptography/
    # NB even though we have CHACHA20 here, the OpenSSL library that ships with Ubuntu 16.04 does not have it. so this is a nop. no problema.
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!aNULL:!MD5;

    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    location = /favicon.ico {
        return 204;
        access_log off;
        log_not_found off;
    }

    location / {
        root /opt/gogs/public;
        try_files \$uri @gogs;
    }

    location @gogs {
        client_max_body_size 50m;
        proxy_pass http://localhost:3000;
    }
}
EOF
rm /etc/nginx/sites-enabled/default
ln -s ../sites-available/gogs /etc/nginx/sites-enabled/gogs
systemctl restart nginx
