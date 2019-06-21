#!/usr/bin/env bash

cat <<'EOF' > /etc/exports
/etc/elasticsearch/elasticsearch-backup 192.168.120.21(rw,sync,no_root_squash)
/etc/elasticsearch/elasticsearch-backup 192.168.120.22(rw,sync,no_root_squash)
/etc/elasticsearch/elasticsearch-backup 192.168.120.23(rw,sync,no_root_squash)
EOF

systemctl restart nfs-server && systemctl enable nfs-server
