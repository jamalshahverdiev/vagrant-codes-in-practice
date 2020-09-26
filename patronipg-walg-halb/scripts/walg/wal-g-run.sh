#!/bin/bash
set -e

source /etc/wal-g.d/server-s3.conf
. /usr/local/bin/walg-functions.sh
checkVariables

/usr/local/bin/wal-g $1 $2 $3 $4 $5
