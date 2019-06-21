#!/usr/bin/env bash

repo_name=$1
token='rDNSbhbuDzXtB-Qnc5Wt'
gitlab_host="http://10.1.42.212"

test -z $repo_name && echo "Repo name required." 1>&2 && exit 1

curl -H "Content-Type:application/json" ${gitlab_host}/api/v4/projects?private_token=$token -d "{ \"name\": \"$repo_name\" }"
