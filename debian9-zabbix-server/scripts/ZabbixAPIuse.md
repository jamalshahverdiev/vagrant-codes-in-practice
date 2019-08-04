#### Get Auth token from Zabbix API:

```bash
# curl -s -X POST -H 'Content-type:application/json' -d '{"jsonrpc":"2.0","method":"user.login","params":{ "user":"admin","password":"Zumrud123"},"auth":null,"id":0}' http://10.3.55.100/zabbix/api_jsonrpc.php | jq -r .result
```

#### Get information only about **pgsqlsrv** host:
```bash
# curl -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"host.get","params":{"output":"extend","filter":{"host":"pgsqlsrv"}},"auth":"3d7b4f878af852f6cb7204b20e33774a","id":1}' http://10.3.55.100/zabbix/api_jsonrpc.php | jq
```

#### Get list of all hosts:
```bash
# curl -s -X POST -H 'Content-Type: application/json' -d @getAllhosts.json http://10.3.55.100/zabbix/api_jsonrpc.php | jq
{
  "jsonrpc": "2.0",
  "result": [
    {
      "hostid": "10106",
      "host": "pgsqlsrv",
      "interfaces": [
        {
          "interfaceid": "2",
          "ip": "10.3.55.55"
        }
      ]
    },
    {
      "hostid": "10084",
      "host": "Zabbix server",
      "interfaces": [
        {
          "interfaceid": "1",
          "ip": "127.0.0.1"
        }
      ]
    }
  ],
  "id": 2
}
# cat getAllhosts.json
{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": [
            "hostid",
            "host"
        ],
        "selectInterfaces": [
            "interfaceid",
            "ip"
        ]
    },
    "id": 2,
    "auth": "3d7b4f878af852f6cb7204b20e33774a"
}

```

#### Get resource information only about **pgsqlsrv** host by itself ID number **10106http://10.3.55.100/zabbix/api_jsonrpc.php**:
```bash
# curl -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"item.get","params":{"output":"extend","filter":{"hostid":"10106"}},"auth":"3d7b4f878af852f6cb7204b20e33774a","id":1}' http://10.3.55.100/zabbix/api_jsonrpc.php | jq
```
