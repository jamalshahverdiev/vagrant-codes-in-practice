#!/usr/bin/env bash

if [ $# -ne 2 ]
then
  echo "Usage: $0 yourdomain.com caKeyPass"
  exit 1
fi

domain=$1
cn="*.$domain"
cacn='caroot'
pass=$2

createCAkeyAndCert () {
openssl genrsa -passout "pass:$1" -des3 -out ca.key 4096 
openssl req -new -passin "pass:$1" -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=AZ/ST=Baku/L=Baku/CN=$cacn" 
}

createSrvKeyAndCSR () {
openssl genrsa -out $domain.key 4096 
openssl req -new -key $domain.key -out $domain.csr -subj "/C=AZ/ST=Baku/L=Baku/CN=$cn/" -reqexts SAN -config <(cat /vagrant/scripts/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:$domain,DNS:*.$domain,DNS:www.$domain,DNS:*.propbx.loc,DNS:propbx.loc"))
}

signSrvCsrWithCaKey () {
openssl x509 -req -passin "pass:$1" -in $domain.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $domain.crt -days 3650 -extfile <(cat /vagrant/scripts/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:$domain,DNS:*.$domain,DNS:www.$domain,DNS:*.propbx.loc,DNS:propbx.loc")) -extensions SAN 
}

createUnusedp12 () {
openssl pkcs12 -export -passout "pass:$1" -in $domain.crt -inkey $domain.key -certfile ca.crt -name $cn -caname $cacn -out $domain.p12 
}

if [ ! -f ca.key -a ! -f ca.crt ]
then
  createCAkeyAndCert $pass
  echo -e "\n *** CA Certificate and Key files generated successfull*** \n"
fi

createSrvKeyAndCSR
signSrvCsrWithCaKey $pass
echo -e "\n *** Server Key and CSR generated and signed with CA key file successful ***\n"
