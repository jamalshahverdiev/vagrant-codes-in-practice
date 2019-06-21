### All these codes deploy Consul Cluster with VAULT HA in the 5 machines. 

#### Between Consul Server and Client nodes will be used TLS. At the same time between Consul and Vault configured HTTPS. Vault client have to use HTTPS to connect to the server.

##### To deploy everything use the following command:
```bash
# git clone https://github.com/jamalshahverdiev/vagrant-codes-in-practice.git && cd vagrant-codes-in-practice/vault-ha-with-consul-cluster
# vagrant up
```

##### After deployment you need to see the following output with machines:
```bash
$ vagrant.exe status | grep running
consulserver1             running (virtualbox)
consulserver2             running (virtualbox)
consulserver3             running (virtualbox)
consulagent1              running (virtualbox)
consulagent2              running (virtualbox)
```

##### Try to connect to the one of the Consul agent nodes and look at the members:
```bash
$ vagrant.exe ssh consulagent2
Last login: Sat Sep 22 17:28:06 2018 from 10.0.2.2
[vagrant@convalc2 ~]$ sudo su -
Last login: Sat Sep 22 17:28:48 UTC 2018 on pts/0
[root@convalc2 ~]# consul members -http-addr=https://cert.domain.name:8500
Node       Address           Status  Type    Build  Protocol  DC   Segment
consul_s1  10.1.42.101:8301  alive   server  1.2.3  2         dc1  <all>
consul_s2  10.1.42.102:8301  alive   server  1.2.3  2         dc1  <all>
consul_s3  10.1.42.103:8301  alive   server  1.2.3  2         dc1  <all>
consul_c1  10.1.42.201:8301  alive   client  1.2.3  2         dc1  <default>
consul_c2  10.1.42.202:8301  alive   client  1.2.3  2         dc1  <default>
```

##### Look at the CLUSTER leader:
```bash
[root@convalc2 ~]# consul operator raft list-peers -http-addr=https://$3:8500
Node       ID                                    Address           State     Voter  RaftProtocol
consul_s1  44366bb8-3651-2768-8eb4-1c8d482ef68a  10.1.42.101:8300  leader    true   3
consul_s2  ff13f07d-6ace-5624-b2c9-635ef54d9bf6  10.1.42.102:8300  follower  true   3
consul_s3  d3ce9e88-6105-f214-301a-f88b7e2e1e4e  10.1.42.103:8300  follower  true   3
```

##### Between Consul agent in server and client mode I have used Enrypt key. If you want to generate the new encrypt key in the CLUSTER just use the following command:
```bash
# consul keygen
```

##### After deployment to call vault use the following environment variable (As we see our server is not initialized):
```bash
[root@convalc2 ~]# vault status --tls-skip-verify
Error checking seal status: Error making API request.

URL: GET https://127.0.0.1:8200/v1/sys/seal-status
Code: 400. Errors:

* server is not yet initialized
```

##### Initialize new Vault server to store keys in the vault/ db in the consul (Of course output in your case will be different):
```bash
[root@convalc2 ~]# vault operator init -key-shares=3 -key-threshold=2
Unseal Key 1: 9Jsf9F0xRP3okJNAW1JU4k6tWhlHxso+ApBGw2awvXpg
Unseal Key 2: oRaN1v5tSK1pwlsB1S2hjFm6gx1FiWfljaINbKlcWEKU
Unseal Key 3: cQKs8TbOs/WGyinHuYHBvjfUb70V5ARZyTPAXwP5jtjc

Initial Root Token: ace35853-6e71-0202-6eb1-4db31e3b9d06

Vault initialized with 3 key shares and a key threshold of 2. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 2 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 2 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

##### From previous command as we see our database is sealed. To unseal just use the following command. Then write some credential to the database and read it:
```bash
[root@convalc2 ~]# vault operator unseal 9Jsf9F0xRP3okJNAW1JU4k6tWhlHxso+ApBGw2awvXpg
Key                Value
---                -----
Seal Type          shamir
Sealed             true
Total Shares       3
Threshold          2
Unseal Progress    1/2
Unseal Nonce       9a0ada86-df53-959b-85f3-c45280689eea
Version            0.11.1
HA Enabled         true
[root@convalc2 ~]# vault operator unseal oRaN1v5tSK1pwlsB1S2hjFm6gx1FiWfljaINbKlcWEKU
Key                    Value
---                    -----
Seal Type              shamir
Sealed                 false
Total Shares           3
Threshold              2
Version                0.11.1
Cluster Name           vault-cluster-53690fe5
Cluster ID             a8e76233-e224-1a86-3ba0-337dd84093c4
HA Enabled             true
HA Cluster             n/a
HA Mode                standby
Active Node Address    <none>
[root@convalc2 ~]# vault login ace35853-6e71-0202-6eb1-4db31e3b9d06
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                ace35853-6e71-0202-6eb1-4db31e3b9d06
token_accessor       41afc994-e689-372b-6983-d2815340fc34
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

[root@convalc2 ~]# vault write secret/db-staging name=sa password=1
Success! Data written to: secret/db-staging
[root@convalc2 ~]# vault read secret/db-staging
Key                 Value
---                 -----
refresh_interval    768h
name                sa
password            1
```


##### At the end unseal consul DB in the first node and read the database which we created in the second node:
```bash
[root@convalc1 ~]# vault read secret/db-staging
Key                 Value
---                 -----
refresh_interval    768h
name                sa
password            1
```
