#!/usr/bin/env bash

if [ $# != 1 ]
then
    echo "To take,restore or delete snapshot please use script with the following syntax"
    echo "Usage: ./$(basename $0) take/restore/delete"
    exit 199
fi


vms="heketi prodgluster01 prodgluster02 prodgluster03"

takeSnapshot() {
    for snapshot in $vms
    do
        vagrant snapshot save $snapshot $snapshot
    done
}


resoreSnapshot() {
    for snapshot in $vms
    do
        vagrant snapshot restore $snapshot $snapshot
    done
}

deleteSnapshot() {
    for snapshot in $vms
    do
        vagrant snapshot delete $snapshot $snapshot
    done
}

if [ $1 = take ]
then
    takeSnapshot
    echo
    echo "The list of the snapshots:"
    vagrant.exe snapshot list
elif [ $1 = restore ]
then
    resoreSnapshot
else
    deleteSnapshot
fi
