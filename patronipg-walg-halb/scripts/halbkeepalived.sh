#!/usr/bin/env bash

yum install -y keepalived psmisc

cat <<'EOF' > /etc/keepalived/keepalived.conf
global_defs {
    # Keepalived process identifier
    lvs_id haproxy_pgw
}

# Script used to check if HAProxy is running
vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 2
    weight 2
}

# Virtual interface
# The priority specifies the order in which the assigned interface to take over in a failover
vrrp_instance VIPGW_01 {
    state MASTER
    interface eth1
    virtual_router_id 57
    priority 105

# The virtual ip address shared between the two loadbalancers
    virtual_ipaddress {
	10.1.42.225
    }
    track_script {
        check_haproxy
    }
}
EOF

systemctl enable keepalived --now
