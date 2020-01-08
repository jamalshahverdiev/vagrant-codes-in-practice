#!/usr/bin/env bash
#Exit code "155" means required parameters are not enough
if [ "$#" -ne 3 ]
then
    echo "Usage: ./$(basename $0) ROOT_TOKEN POLICY_NAME APPROLE_NAME"
    exit 155
fi

export VAULT_ADDR='http://127.0.0.1:8200'
VAULT_TOKEN=$1
IP=$(ifconfig | grep 'inet ' | awk '{ print $2 }' | head -n 1)

create_policy () {
## First argument inside the function represents the policy name $1
## Second argument inside the function represents the role name  $2
    curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d '{"rules": "{\"name\": \"'$1'\", \"path\": {\"secret/*\": {\"policy\": \"read\"}}}"}' http://$IP:8200/v1/sys/policy/$1
    curl -s -H "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"policies": ["'"$1"'"]}' http://$IP:8200/v1/auth/approle/role/$2
    roleid=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" http://$IP:8200/v1/auth/approle/role/$2/role-id | jq -r .data.role_id)
    secretid=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" --request POST http://$IP:8200/v1/auth/approle/role/$2/secret-id | jq -r .data.secret_id)
    client_token=$(curl -s -H POST --data '{"role_id": "'"$roleid"'", "secret_id": "'"$secretid"'"}' http://$IP:8200/v1/auth/approle/login | jq -r .auth.client_token)
    echo -e "\n This token for the new role $2: $client_token"
}
create_policy $2 $3

