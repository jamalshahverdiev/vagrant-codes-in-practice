### All these codes deploy Nomad Cluster with the Consul Cluster in the 5 machines. 

#### Nomad servers and nodes will automatically connect to the Consul servers and agents.

##### To deploy everything use the following command:
```bash
# git clone https://github.com/jamalshahverdiev/vagrant-codes-in-practice.git && cd vagrant-codes-in-practice/vagrant-nomad-consul-vault
# vagrant up && vagrant ssh nomadagent2
```

##### After deployment you need to see the following output with the server nodes:
```bash
$ sudo su -
# nomad server members
Name                    Address      Port  Status  Leader  Protocol  Build  Datacenter  Region
nomadconsulsrv1.global  10.1.42.101  4648  alive   true    2         0.8.6  dc1         global
nomadconsulsrv2.global  10.1.42.102  4648  alive   false   2         0.8.6  dc1         global
nomadconsulsrv3.global  10.1.42.103  4648  alive   false   2         0.8.6  dc1         global
```

##### To look at the list of all nodes use the following command:
```bash
# nomad node status
ID        DC   Name               Class   Drain  Eligibility  Status
4828d32f  dc1  nomadconsulagent2  <none>  false  eligible     ready
df0a9f35  dc1  nomadconsulagent1  <none>  false  eligible     ready
3c85ca72  dc1  nomadconsulsrv1    <none>  false  eligible     ready
fbb79d22  dc1  nomadconsulsrv3    <none>  false  eligible     ready
6418d463  dc1  nomadconsulsrv2    <none>  false  eligible     ready
```

##### Look at the all Job statuses:
```bash
# nomad job status
ID              Type     Priority  Status   Submit Date
dockerNginxApp  service  50        running  2019-01-10T21:51:59Z
javaJob         service  50        running  2019-01-10T21:52:00Z
pythonApp       service  50        running  2019-01-10T21:52:01Z
```

##### Look at the deployment list:
```bash
# nomad deployment list
ID        Job ID   Job Version  Status      Description
86f9f65b  javaJob  0            successful  Deployment completed successfully
```

##### Look at the deployment status of the "ID: 86f9f65b":
```bash
# nomad deployment status 86f9f65b
ID          = 86f9f65b
Job ID      = javaJob
Job Version = 0
Status      = successful
Description = Deployment completed successfully

Deployed
Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
webapp      1        1       1        0          2019-01-10T22:02:37Z
```

##### Look at the Job status with the "ID: pythonApp":
```bash
# nomad job status pythonApp
ID            = pythonApp
Name          = pythonApp
Submit Date   = 2019-01-11T07:50:41Z
Type          = service
Priority      = 50
Datacenters   = dc1
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
server      0       0         1        0       0         0

Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created  Modified
fbf7b184  3c85ca72  server      0        run      running  17s ago  14s ago
```

##### Look at the allocation status(-verbose will print more detail) of the "ID: fbf7b184":
```bash
# nomad alloc status fbf7b184
ID                  = fbf7b184
Eval ID             = 2e999fdf
Name                = pythonApp.server[0]
Node ID             = 3c85ca72
Job ID              = pythonApp
Job Version         = 0
Client Status       = running
Client Description  = <none>
Desired Status      = run
Desired Description = <none>
Created             = 3m31s ago
Modified            = 3m11s ago

Task "pythonApp" is "running"
Task Resources
CPU         Memory          Disk     IOPS  Addresses
23/500 MHz  30 MiB/256 MiB  300 MiB  0     http: 10.1.42.101:9080

Task Events:
Started At     = 2019-01-11T07:50:44Z
Finished At    = N/A
Total Restarts = 0
Last Restart   = N/A

Recent Events:
Time                  Type                   Description
2019-01-11T07:50:44Z  Started                Task started by client
2019-01-11T07:50:43Z  Downloading Artifacts  Client is downloading artifacts
2019-01-11T07:50:41Z  Task Setup             Building Task Directory
2019-01-11T07:50:41Z  Received               Task received by client
```

##### Look at the allocation logs(-tail -f read online) of the "ID: fbf7b184": 
```bash
# nomad alloc logs fbf7b184 | tail -n5
 * Serving Flask app "routes" (lazy loading)
 * Environment: production
   WARNING: Do not use the development server in a production environment.
   Use a production WSGI server instead.
 * Debug mode: on
```

##### Look at the file system content of the allocation "ID: fbf7b184":
```bash
# nomad alloc fs -verbose fbf7b184 pythonApp/local/
Mode        Size     Modified Time         Name
-rwxr-xr-x  91 B     2019-01-10T20:34:21Z  dlLibsRun.sh
-rw-r--r--  150 B    2019-01-10T20:30:09Z  requirements.txt
-rw-r--r--  527 B    2019-01-10T20:32:59Z  routes.py
drwxr-xr-x  4.0 KiB  2019-01-10T20:30:09Z  static/
drwxr-xr-x  4.0 KiB  2019-01-10T20:30:09Z  templates/
```

##### After deployment of Docker, Java and Python applications we must open the Nomad UI page with this URL *http://10.1.42.101:4646* and see the following output:
![Nomad UI image](https://github.com/jamalshahverdiev/vagrant-codes-in-practice/blob/master/vagrant-nomad-consul-vault/images/nomadui.png)

##### To look services in Consul UI use this URL *http://10.1.42.101:8500*:
![Consul UI image](https://github.com/jamalshahverdiev/vagrant-codes-in-practice/blob/master/vagrant-nomad-consul-vault/images/consului.png)

##### To get Java Application listener we can use the following commands:
```bash
# jobName=$(nomad job status | grep java | awk '{ print $1 }')
# javaAllocID=$(nomad job status $jobName | tail -n1 | awk '{ print $1 }')
# javaAppIP=$(nomad alloc status $javaAllocID | grep http | awk '{ print $(NF)}')
# echo "http://$javaAppIP"
http://10.1.42.102:8080
```

##### Open the URL *http://10.1.42.102:8080* to see the Java Spring page:
![Spring URL Image](https://github.com/jamalshahverdiev/vagrant-codes-in-practice/blob/master/vagrant-nomad-consul-vault/images/spring.png)



##### To get Docker Application listener we can use the following commands:
```bash
# dockerJobName=$(nomad job status | grep docker | awk '{ print $1 }')
# dockerJobID=$(nomad job status $dockerJobName | tail -n1 | awk '{ print $1 }')
# echo http://$(nomad alloc status $dockerJobID | grep web_port | awk '{ print $(NF)}')
http://10.1.42.101:8889
```

##### Open the URL *http://10.1.42.101:8889* to see the dockered Nginx page:
![Spring URL Image](https://github.com/jamalshahverdiev/vagrant-codes-in-practice/blob/master/vagrant-nomad-consul-vault/images/docker.png)



##### To get Python Application listener we can use the following commands:
```bash
# pythonJobName=$(nomad job status | grep python | awk '{ print $1 }')
# pythonJobID=$(nomad job status $pythonJobName | tail -n1 | awk '{ print $1 }')
# echo http://$(nomad alloc status $pythonJobID | grep http | awk '{ print $(NF)}')
http://10.1.42.101:9080
```

##### Open the URL *http://10.1.42.101:9080* to see the Python Flask page:
![Spring URL Image](https://github.com/jamalshahverdiev/vagrant-codes-in-practice/blob/master/vagrant-nomad-consul-vault/images/python.png)
