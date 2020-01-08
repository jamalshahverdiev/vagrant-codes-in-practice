#!/usr/bin/env bash
if [ "$#" -ne 6 ]
then
        echo "Usage: ./$(basename $0) Root_Token Policy_Name Approle_Name Secret_Name New_Token Domain"
        exit 155
fi

export VAULT_ADDR='http://active.vault.service.consul:8200'


###Get The Duration###
duration=$(/usr/local/bin/vault login $(cat /root/scripts/$5.txt) | grep token_duration | awk '{ print $2  }' | grep -Po '[^;:]+(?=h)')

if [ $duration -lt 24 ]
then
   echo  "Token expired, lets update the token"
   new_token=$(/root/scripts/approle_and_policy.sh $1 $2 $3 $4 | tail -n1 | cut -f2 -d":")
   echo $new_token > ./token.txt
   sed -i "s/$(cat /root/scripts/$5.txt)/$new_token/g" /var/www/public_html/core.$6/config/runtime-evaluated.php
   if [ $(grep $new_token /var/www/public_html/core.$6/config/runtime-evaluated.php | tr -d '",    ') ==  $new_token ]
   then
        echo The new Token written successful
        echo "$new_token" > /root/scripts/$5.txt
   fi
else
   echo "The token is not expired yet "
fi
