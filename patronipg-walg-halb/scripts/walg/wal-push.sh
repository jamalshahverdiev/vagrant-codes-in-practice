#!/bin/bash
set -e


source /etc/wal-g.d/server-s3.conf
. /usr/local/bin/walg-functions.sh
checkVariables

echo "Full path of archived WAL: $PGDATA/$1" >> ~/wal-incremental.log

/usr/local/bin/wal-g wal-push $PGDATA/$1
