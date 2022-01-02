couchbase-cli node-init \
  --cluster 127.0.0.1:8091 \
  --username=Administrator \
  --password=password \
  --node-init-data-path='/opt/couchbase/var/lib/couchbase/data' \
  --node-init-index-path='/opt/couchbase/var/lib/couchbase/indexes' \
  --node-init-hostname=${NODE_INIT_HOSTNAME:='127.0.0.1'}





couchbase-cli server-add \
-c http://172.21.0.2:8091 \
--username Administrator \
--password password \
--server-add 172.21.0.3 \
--server-add-username Administrator \
--server-add-password password \
 --services data,index,query


INITIAL_CLUSTER_HOST=couchbase-node_1
CLUSTER_USERNAME=Administrator
CLUSTER_PASSWORD=password
SERVICES=data,index,query

echo /opt/couchbase/bin/couchbase-cli server-add \
    --cluster couchbase://$(getent hosts $INITIAL_CLUSTER_HOST | awk '{ print $1 }') \
    --username=$CLUSTER_USERNAME \
    --password=$CLUSTER_PASSWORD \
    --server-add="http://$(getent hosts $HOSTNAME | awk '{ print $1 }'):8091" \
    --server-add-username=$CLUSTER_USERNAME \
    --server-add-password=$CLUSTER_PASSWORD \
    --services=$SERVICES 









 echo /opt/couchbase/bin/couchbase-cli server-add \
    --cluster couchbase://$(getent hosts $INITIAL_CLUSTER_HOST | awk '{ print $1 }') \
    --username=$CLUSTER_USERNAME \
    --password=$CLUSTER_PASSWORD \
    --server-add="$(ifconfig eth0 | grep inet | grep -o 'inet addr:[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | cut -c 11-):8091" \
    --server-add-username=$CLUSTER_USERNAME \
    --server-add-password=$CLUSTER_PASSWORD \
    --services=$SERVICES 


