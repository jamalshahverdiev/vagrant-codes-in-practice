#!/usr/bin/env bash

cat <<EOF >> /etc/fstab
$1:/etc/elasticsearch/elasticsearch-backup /etc/elasticsearch/elasticsearch-backup nfs defaults 0 0
EOF

mount -a

if [ "$(hostname)" != "elknd3" ]
then
    echo This node most be the last one!
    exit 0
fi

while [ "$(curl -s -XGET "http://$1:9200/_cluster/state?pretty" | jq '.nodes' | grep 9300 | wc -l)" != "4" ]
do
    sleep 3
    echo "Waiting until full cluster environment will be up and running!"
done


wget https://download.elastic.co/demos/kibana/gettingstarted/shakespeare_6.0.json
wget https://download.elastic.co/demos/kibana/gettingstarted/accounts.zip
unzip accounts.zip
wget https://download.elastic.co/demos/kibana/gettingstarted/logs.jsonl.gz
gunzip logs.jsonl.gz

curl -s -H "Content-Type: application/json" -XPOST http://$1:9200/shakespeare/doc/_bulk?pretty --data-binary @shakespeare_6.0.json
curl -s -H "Content-Type: application/json" -XPOST http://$1:9200/_bulk?pretty --data-binary @logs.jsonl
curl -s -H "Content-Type: application/json" -XPOST http://$1:9200/bank/account/_bulk?pretty --data-binary @accounts.json

indexCount=$(curl -s -H "Content-Type: application/json" -XGET http://$1:9200/_cat/indices?v | grep -v index | awk '{ print $3 }' | wc -l)

if [ "$indexCount" -gt "3" ]
then
    echo Cluster successfully imported all data files.
fi


curl -s -H 'Content-Type: application/json' -XPUT "http://$1:9200/_snapshot/all-backup" -d '
{
   "type": "fs",
   "settings": {
       "compress" : true,
       "location": "/etc/elasticsearch/elasticsearch-backup"
   }
}'

curl -s -H 'Content-Type: application/json' -XPUT "http://$1:9200/_snapshot/all-backup/snapshot-number-one?wait_for_completion=true"
curl -s -H 'Content-Type: application/json' -XGET "http://$1:9200/_snapshot/_all"
