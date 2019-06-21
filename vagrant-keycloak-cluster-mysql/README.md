#### Keycloak is the OpenSource SSO with Identity Management/Access Management and with wonderful RestfulAPI. It is very useful in the software development environment. In this article, I will deploy Keycloak Cluster with the Shared MySQL database. In the end, I will show some examples using of the Keycloak API with curl.
 
##### Download all code files and run vagrant:
```bash
$ git clone https://github.com/jamalshahverdiev/vagrant-keycloak-cluster-mysql.git && cd vagrant-keycloak-cluster-mysql
$ vagrant up
```

##### Note: Don't forget the Authorization Token by default expired in a minute.
```bash
[root@mysqlsrv ~]# TKN=$(curl -s -d "client_id=admin-cli" -d "username=admin" -d "password=admin" -d "grant_type=password" "http://10.1.200.41:8080/auth/realms/master/protocol/openid-connect/token" | jq '.access_token' | tr -d '"')
```

##### Try to authorize with this token and get information about the 'master' realm:
```bash
[root@mysqlsrv ~]# curl -s -H "Authorization: bearer $TKN" "http://10.1.200.42:8080/auth/realms/master" | jq
{
  "realm": "master",
  "public_key": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAigNBbZRUdRoQKplRmepdyqOdNCMKbtHB/YdLucEGt3fyhZkb+9dpSDMzYbhgPL+Z/t6+tnO+liMKF9dvzjyaZHRorGBJcArDk/S7r4iWUWUckT4Yzbe5+EiMGxh4BoJbQMMgyVXbaykQL1jwl8wipYLgciwAGl/QuM5gaLWmaWNPJ3g0oru9IabD2UQOO6maEwdjmwVOsnhk5UMKTreuY0CUAY01C5I7TldIfGUau/PRcI9OhYSvgYcfSUV4Q5JikKgb0wiS3VEuoSQFkQ5r9gpRT6IuN1F/C3BPiPyheFEeqUP9MFfiVg71TyMqq6Zl+3UDeBDwTxjECzIc3n0KvwIDAQAB",
  "token-service": "http://10.1.200.42:8080/auth/realms/master/protocol/openid-connect",
  "account-service": "http://10.1.200.42:8080/auth/realms/master/account",
  "tokens-not-before": 0
}
```

##### Get user information of admin account of the 'master' realm:
```bash
[root@mysqlsrv ~]# curl -s -H "Authorization: bearer $TKN" http://10.1.200.41:8080/auth/realms/master/protocol/openid-connect/userinfo | jq                                     {
  "sub": "38bd04c3-b3ed-4711-854c-5ffea88bec8f",
  "email_verified": false,
  "preferred_username": "admin"
}
```

##### Create new user under 'Master' realm:
```bash
[root@mysqlsrv ~]# curl -s -X POST 'http://10.1.200.41:8080/auth/admin/realms/master/users?realm=master' \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-H "Authorization: Bearer $TKN" \
-d '{"username" : "elvin", "enabled": true, "email" : "elvin@example.com", "firstName": "Elvin", "lastName": "Asadov", "credentials" : [{ "type" : "password", "value" : "freebsd" } ], "realmRoles": [ "user", "offline_access"  ], "clientRoles": {"account": [ "manage-account" ] } }' | jq 
```

##### Get the list of all users:
```bash
[root@mysqlsrv ~]# curl -XGET 'http://10.1.200.41:8080/auth/admin/realms/master/users?realm=master' -H "Authorization: Bearer $TKN" | jq
```

##### Select USER ID (This user under the third index):
```bash
[root@mysqlsrv ~]# elvinID=$(curl -s -XGET 'http://10.1.200.41:8080/auth/admin/realms/master/users?realm=master' -H "Authorization: Bearer $TKN" | jq '.[2].id' | tr -d '"')
```

##### Reset password for this user:
```bash
[root@mysqlsrv ~]# curl -X PUT "http://10.1.200.41:8080/auth/admin/realms/master/users/$elvinID/reset-password" \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-H "Authorization: Bearer $TKN" \
-d '{ "type" : "password", "value" : "newpassword" }' | jq .
```
