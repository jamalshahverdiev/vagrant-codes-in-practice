#### Get Auth token from Zabbix API:

```bash
# curl -s -X POST -H 'Content-type:application/json' -d '{"jsonrpc":"2.0","method":"user.login","params":{ "user":"admin","password":"Zumrud123"},"auth":null,"id":0}' http://10.3.55.100/zabbix/api_jsonrpc.php | jq -r .result
```


