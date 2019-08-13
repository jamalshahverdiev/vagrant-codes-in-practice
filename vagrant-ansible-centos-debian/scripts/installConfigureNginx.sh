#!/usr/bin/env bash

if [ $# -lt 1 ]
then
    echo "Usage: $0 domainName"
    exit 103
fi

#### Web server configure
apt-get -y install nginx
systemctl start nginx.service && systemctl enable nginx.service
apt install apt-transport-https ca-certificates curl software-properties-common -y
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list
curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -
add-apt-repository "deb https://packages.sury.org/php/ $(lsb_release -cs) main"
apt-get update
apt install -y php7.2-common php7.2-cli php7.2-fpm php7.2-zip php7.2-bcmath php7.2-mbstring php7.2-gd php7.2-xml php7.2-dev php7.2-curl composer
systemctl start php7.2-fpm.service && systemctl enable php7.2-fpm.service


#### SQLSRV and Pdo_SQLSRV driver
curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && locale-gen
pecl channel-update pecl.php.net && pecl install sqlsrv pdo_sqlsrv
printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.2/mods-available/sqlsrv.ini
printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini
phpenmod -v 7.2 sqlsrv pdo_sqlsrv

cp /vagrant/scripts/nginxVhostTemp.conf /etc/nginx/conf.d/$1.conf
sed -i "s/domainname/$1/g" /etc/nginx/conf.d/$1.conf
cat /home/vagrant/$1.{crt,key} | tee -a /home/vagrant/{agent,wss}.pem 
cat /home/vagrant/ca.crt > /home/vagrant/cafile.pem
mkdir -p /var/www/public_html/$1 /etc/nginx/certs && cp /home/vagrant/$1.{crt,key} /etc/nginx/certs/
systemctl restart php7.2-fpm.service && systemctl restart nginx.service

