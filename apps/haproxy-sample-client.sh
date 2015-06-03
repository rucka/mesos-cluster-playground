#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
mkdir /tmp/hellobridge

tar czf /tmp/hellobridge/hellobridge.tar.gz -C $DIR/../projects hellobridge
export MASTER=$(mesos-resolve `cat /etc/mesos/zk` 2>/dev/null)
export MARATHON=$(echo $MASTER | sed 's/5050/8080/g')

curl -F "name=file" -F "filename=hellonode.tar.gz" -F "file=@/tmp/hellobridge/hellobridge.tar.gz" http://$MARATHON/v2/artifacts
rm -rf /tmp/hellobridge

curl -X POST -H "Content-Type: application/json" http://$MARATHON/v2/apps -d@$DIR/haproxy-sample-client.json
