#!/usr/bin/env bash

cat <<EOF > /etc/default/etcd
ETCD_LISTEN_PEER_URLS="http://$121:2380"
ETCD_LISTEN_CLIENT_URLS="http://localhost:2379,http://$121:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://$121:2380"
ETCD_INITIAL_CLUSTER="etcd0=http://$121:2380,"
ETCD_ADVERTISE_CLIENT_URLS="http://$121:2379"
ETCD_INITIAL_CLUSTER_TOKEN="cluster1"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

systemctl enable etcd && systemctl restart etcd
