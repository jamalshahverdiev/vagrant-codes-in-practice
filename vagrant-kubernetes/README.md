### All these codes deploy Kubernetes Cluster with Vagrant in 4 machines. 

#### Kubemaster (API server and manager node) and Kubenode1, Kubenode2, Kubenode3 worker nodes  

##### To deploy everything use the following command:
```bash
# git clone https://github.com/jamalshahverdiev/vagrant-codes-in-practice.git && cd vagrant-codes-in-practice/vagrant-kubernetes
# vagrant up && vagrant ssh kubemaster
```

##### After deployment you need to see the following output with all nodes:
```bash
[vagrant@kubemaster ~]$ kubectl get nodes
NAME         STATUS   ROLES    AGE     VERSION
kubemaster   Ready    master   9m39s   v1.14.0
kubenode1    Ready    <none>   7m17s   v1.14.0
kubenode2    Ready    <none>   3m24s   v1.14.0
kubenode3    Ready    <none>   39s     v1.14.0
```

##### Look at the list of all PODs in the **kube-system** namespace:
```bash
[vagrant@kubemaster ~]$ kubectl get pods -n kube-system
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-fb8b8dccf-2ps7w              1/1     Running   0          9m38s
coredns-fb8b8dccf-5jgdq              1/1     Running   0          9m38s
etcd-kubemaster                      1/1     Running   0          8m51s
kube-apiserver-kubemaster            1/1     Running   0          8m59s
kube-controller-manager-kubemaster   1/1     Running   0          8m40s
kube-flannel-ds-amd64-8czw7          1/1     Running   0          59s
kube-flannel-ds-amd64-d8qv2          1/1     Running   0          3m44s
kube-flannel-ds-amd64-m2kbd          1/1     Running   0          9m38s
kube-flannel-ds-amd64-xg6gw          1/1     Running   2          7m37s
kube-proxy-57srv                     1/1     Running   0          7m37s
kube-proxy-9skr8                     1/1     Running   0          9m38s
kube-proxy-k699b                     1/1     Running   0          59s
kube-proxy-vzlfh                     1/1     Running   0          3m44s
kube-scheduler-kubemaster            1/1     Running   0          8m31s
```
