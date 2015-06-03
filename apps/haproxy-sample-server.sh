#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
mkdir /tmp/hellonode

tar czf /tmp/hellonode/hellonode.tar.gz -C $DIR/../projects hellonode
#ls /tmp/hellonode
export MASTER=$(mesos-resolve `cat /etc/mesos/zk` 2>/dev/null)
export MARATHON=$(echo $MASTER | sed 's/5050/8080/g')

curl -F "name=file" -F "filename=hellonode.tar.gz" -F "file=@/tmp/hellonode/hellonode.tar.gz" http://$MARATHON/v2/artifacts
rm -rf /tmp/hellonode

curl -X POST -H "Content-Type: application/json" http://$MARATHON/v2/apps -d@$DIR/haproxy-sample-server.json
