#!/bin/bash
export MASTER=$(mesos-resolve `cat /etc/mesos/zk` 2>/dev/null)
export MARATHON=$(echo $MASTER | sed 's/5050/8080/g')

curl -X POST -H "Content-Type: application/json" http://$MARATHON/v2/apps -d@chronos-docker.json
