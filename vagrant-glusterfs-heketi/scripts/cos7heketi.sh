#!/usr/bin/env bash

cat <<EOF > /etc/hosts
192.168.10.41 heketi
192.168.10.21 prodgluster01
192.168.10.22 prodgluster02
192.168.10.23 prodgluster03
127.0.0.1     localhost
EOF

yum -y install centos-release-gluster6 && yum makecache && yum -y install glusterfs-server

useradd -m -d /home/$2 --shell=/sbin/nologin $2
mkdir -p /var/log/$2 /var/run/$2 /etc/$2 /var/lib/$2 

cat <<EOF > /etc/heketi/heketi_key
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAsIhmBB5tv7ItGWo3fP2m0NYDNk/obHUffaM8/MGquGeRlQW8
9dzUrSq97+H38lD8LXNsXgcZeIVzBw5ewzadthcj4DWsoNLcxQnaFjHjAmWZzUeQ
Ur+jJMbI/DbfuNg644aDWJk6vfnPtFgcqzvYkPkj0ZcXcgdcWDpKQsc/Al0RYxAQ
xSFnMxr80qWQgagtJLfzFqyV2+Mxq5tA9SuMhn2FA7GlPOl42feTicY5vqn989jL
Dv/CFkpi2DEGhg3i9s5B4aSfQGCWIMpT6JbfEg8XuN9PXdDn6OtPzpLXBpOLAN4/
UhpYZUxNKPJeL/DTuRXoTwJSWQmRf/+wvCu8iwIDAQABAoIBAQCrYI9hOkUjT49W
1/XsYrb6kHln1aV2/TFIIBwJ6N2azfjYKkzqhqr1PcRMyBuUY6idWyt+EPhaN3uX
Aw1eCHyNFOPgO1tOecaXhtvwpheS8R2h2vKyUpbIEi92IrOIWGq7DZAfiAot+gH5
O30Bg0TYYPWz+DFrote0U0paj+GMoT6DlfOr24hK4K+Ji+xZZ6wkWsPJv2rW7S6R
xkShciNl4MeUecoZLjZjxcyZQlvJEZb0w4vxS5f4QUQjNptaM5X4FomvIqYpUeit
SU9A7bf8VrnSRlpi+0/DIi65Q2bLMSpjCCJlwECgnZDlGXcAN62rLxRnBSVPonY6
bcV+7Q2JAoGBANalR4MzhgygPqaVYCkHMFfP/7fyxbg+Ed7x49fQmDcqowrH8bdY
VUSFXS567XQ/4GPYDYwzOz5MOnCKe8mrVdI6mMHRosOcdPdH2zJ2au/fGW2ZSkFB
8g7T31z2CXvKngNjYeAMfgDddoXHPFvuQLo/EK89EJRwMXCZTF2bDtLPAoGBANKL
UwYOJtSv9tbePMo17qrJyR4wCVahx+ryQQ9X0XvyL6+BlWeLrZFKRgQnqkX8h9zW
Er5vQiArzRQ7xn0zwn+Gbh9pFi88o8TuUvwUt5wHZnLB2XKE3b8bgDvzYM8uz09v
egprqQXqE7awTfOSRJEIkKl2uUiwG2CQi4O3fhmFAoGAMT7iVVuw2Zy6QwXqdf9M
PBlglheA/XBgMUJV/+G/yohht8t/zYzao0nlwxA5An7VQJMFKLFoWjarAb8D/5Tr
r7v56B3stexjeYhm5gD9L+ODtf2BZ891daluial5K4mlDynx/rFfB1vIIZFAa+cR
uqlVbp8X+rZy4V6Kgr9ce0kCgYB0h9qG4nRJia8UU+LPhLQ5YP/ormuswFQ3TKgH
xvJSKMSN3ioEKoIBhVtlV1Ld85x69R1gu5Gc3sFeLot4pppDHPN8fRxjPqviBop1
rT3GpS3l3DbvNGzLJnx+MgFmCqGBdNDWTao6dMk+dyxd4JoEr/npYaXBfn9Ynggp
+fhYRQKBgAKNNE/JmIPc3TE2a8aes66SGwu+ycK3gkk5VwfUozYsfkU9wCbAysF5
cbTRpAatNM6WfFw0cE5MqbfxWaQt+98rU7tJbBLs2rfdLKOlkLitOKGR01Y5Qwno
/x+JCm10PzkHLLXJclU1yhqNy9cARLpXe8w4oxNGwUfwnhn7T5Sd
-----END RSA PRIVATE KEY-----
EOF

cat <<EOF > /etc/heketi/heketi.json
{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",

        "_enable_tls_comment": "Enable TLS in Heketi Server",
        "enable_tls": false,

        "_cert_file_comment": "Path to a valid certificate file",
        "cert_file": "",

        "_key_file_comment": "Path to a valid private key file",
        "key_file": "",


  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  "use_auth": false,

  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "ttyughjsdc8yiu3u98i"
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      "key": "yjhbcer9d8yuikedxsd"
    }
  },

  "_backup_db_to_kube_secret": "Backup the heketi database to a Kubernetes secret when running in Kubernetes. Default is off.",
  "backup_db_to_kube_secret": false,

  "_profiling": "Enable go/pprof profiling on the /debug/pprof endpoints.",
  "profiling": false,

  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
    "_executor_comment": [
      "Execute plugin. Possible choices: mock, ssh",
      "mock: This setting is used for testing and development.",
      "      It will not send commands to any node.",
      "ssh:  This setting will notify Heketi to ssh to the nodes.",
      "      It will need the values in sshexec to be configured.",
      "kubernetes: Communicate with GlusterFS containers over",
      "            Kubernetes exec api."
    ],
    "executor": "ssh",

    "_sshexec_comment": "SSH username and private key file information",
    "sshexec": {
      "keyfile": "/etc/heketi/heketi_key",
      "user": "root",
      "port": "22",
      "fstab": "/etc/fstab",
      "pv_data_alignment": "256K",
      "vg_physicalextentsize": "4MB",
      "lv_chunksize": "256K",
      "backup_lvm_metadata": false,
      "debug_umount_failures": true
    },

    "_kubeexec_comment": "Kubernetes configuration",
    "kubeexec": {
      "host" :"https://kubernetes.host:8443",
      "cert" : "/path/to/crt.file",
      "insecure": false,
      "user": "kubernetes username",
      "password": "password for kubernetes user",
      "namespace": "OpenShift project or Kubernetes namespace",
      "fstab": "/etc/fstab",
      "pv_data_alignment": "256K",
      "vg_physicalextentsize": "4MB",
      "lv_chunksize": "256K",
      "backup_lvm_metadata": false,
      "debug_umount_failures": true
    },

    "_db_comment": "Database file name",
    "db": "/var/lib/heketi/heketi.db",

     "_refresh_time_monitor_gluster_nodes": "Refresh time in seconds to monitor Gluster nodes",
    "refresh_time_monitor_gluster_nodes": 120,

    "_start_time_monitor_gluster_nodes": "Start time in seconds to monitor Gluster nodes when the heketi comes up",
    "start_time_monitor_gluster_nodes": 10,

    "_loglevel_comment": [
      "Set log level. Choices are:",
      "  none, critical, error, warning, info, debug",
      "Default is warning"
    ],
    "loglevel" : "debug",

    "_auto_create_block_hosting_volume": "Creates Block Hosting volumes automatically if not found or exsisting volume exhausted",
    "auto_create_block_hosting_volume": true,

    "_block_hosting_volume_size": "New block hosting volume will be created in size mentioned, This is considered only if auto-create is enabled.",
    "block_hosting_volume_size": 500,

    "_block_hosting_volume_options": "New block hosting volume will be created with the following set of options. Removing the group gluster-block option is NOT recommended. Additional options can be added next to it separated by a comma.",
    "block_hosting_volume_options": "group gluster-block",

    "_pre_request_volume_options": "Volume options that will be applied for all volumes created. Can be overridden by volume options in volume create request.",
    "pre_request_volume_options": "",

    "_post_request_volume_options": "Volume options that will be applied for all volumes created. To be used to override volume options in volume create request.",
    "post_request_volume_options": ""
  }
}
EOF

cat <<EOF > /etc/heketi/topology.json
{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "prodgluster01"
              ],
              "storage": [
                "192.168.10.21"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdb"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "prodgluster02"
              ],
              "storage": [
                "192.168.10.22"
              ]
            },
            "zone": 2
          },
          "devices": [
            "/dev/sdb"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "prodgluster03"
              ],
              "storage": [
                "192.168.10.23"
              ]
            },
            "zone": 3
          },
          "devices": [
            "/dev/sdb"
          ]
        }
      ]
    }
  ]
}
EOF

curl -s https://api.github.com/repos/heketi/heketi/releases/latest | grep browser_download_url | grep linux.amd64 | cut -d '"' -f 4 | wget -qi -
for i in `ls | grep heketi | grep .tar.gz`; do tar xvf $i; done
cp heketi/{heketi,heketi-cli} /usr/local/bin
#wget -O /etc/heketi/heketi.env https://raw.githubusercontent.com/heketi/heketi/master/extras/systemd/heketi.env

chown -R $2:$2 /var/log/$2 /var/run/$2 /etc/$2 /var/lib/$2

cat <<'EOF' > /etc/systemd/system/heketi.service
[Unit]
Description=Heketi Server
Requires=network-online.target
After=network-online.target

[Service]
Environment="HEKETI_GLUSTERAPP_LOGLEVEL=DEBUG"
#Type=simple
WorkingDirectory=/var/lib/heketi
#EnvironmentFile=-/etc/heketi/heketi.env
User=heketi
Group=heketi
PermissionsStartOnly=true
ExecStartPre=-/usr/bin/mkdir -p /var/log/heketi /var/run/heketi /etc/heketi
ExecStartPre=/bin/chown -R heketi:heketi /var/run/heketi /var/log/heketi /etc/heketi /var/lib/heketi
ExecStart=/bin/bash -c "/usr/local/bin/heketi --config=/etc/heketi/heketi.json >> /var/log/heketi/heketi.log 2>&1 & echo $! > /var/run/heketi/heketi.pid"
PIDFile=/var/run/heketi/heketi.pid
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=5
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl enable --now heketi


