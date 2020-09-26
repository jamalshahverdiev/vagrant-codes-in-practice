#!/bin/bash
set -e

source /etc/wal-g.d/server-s3.conf
. /usr/local/bin/walg-functions.sh
checkVariables

/usr/local/bin/wal-g backup-fetch $PGDATA LATEST

