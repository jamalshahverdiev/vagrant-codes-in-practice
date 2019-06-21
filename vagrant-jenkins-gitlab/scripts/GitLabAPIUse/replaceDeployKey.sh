#!/usr/bin/env bash

curl --request POST --header "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" --header "Content-Type: application/json" --data '{"title": "'"$1"'", "key": "'"$2"'", "can_push": "true"}' "http://10.1.42.212/api/v4/projects/4/deploy_keys/"
