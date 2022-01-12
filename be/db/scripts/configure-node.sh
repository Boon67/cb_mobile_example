set -m

### Cluster Level Settings
NODE_TYPE=${NODE_TYPE:='DEFAULT'}
CLUSTER_USERNAME=${CLUSTER_USERNAME:='Administrator'}
CLUSTER_PASSWORD=${CLUSTER_PASSWORD:='password'}
CLUSTER_RAMSIZE=${CLUSTER_RAMSIZE:=300}
CLUSTER_INDEX_RAMSIZE=${CLUSTER_INDEX_RAMSIZE:=256}
CLUSTER_FTS_RAMSIZE=${CLUSTER_FTS_RAMSIZE:=256}
CLUSTER_EVENTING_RAMSIZE=${CLUSTER_EVENTING_RAMSIZE:=256}
CLUSTER_ANALYTICS_RAMSIZE=${CLUSTER_ANALYTICS_RAMSIZE:=1024}
CLUSTER_HOST=${CLUSTER_HOST}

SYNCGATEWAY_SVC_ACCT=${SYNCGATEWAY_SVC_ACCT}
SYNCGATEWAY_PASSWORD=${SYNCGATEWAY_PASSWORD}
SYNCGATEWAY_ROLES=${SYNCGATEWAY_ROLES}

#Node Services
SERVICES=${SERVICES:='data,index,query,fts,eventing,backup'}
NODE_INIT_DATA_PATH=${NODE_INIT_DATA_PATH:='/opt/couchbase/var/lib/couchbase/data'}
NODE_INIT_INDEX_PATH=${NODE_INIT_INDEX_PATH:='/opt/couchbase/var/lib/couchbase/indexes'}
NODE_INIT_HOSTNAME=${NODE_INIT_HOSTNAME:='127.0.0.1'}
INDEX_STORAGE_SETTING=${INDEX_STORAGE_SETTING:=default}
ENABLE_INDEX_REPLICA=${ENABLE_INDEX_REPLICA:=0}

#Data Bucket Configuration Settings
SAMPLE_BUCKETS=${SAMPLE_BUCKETS} ##Sample Buckets Needs to be fixed

BUCKET=${BUCKET}
BUCKET_RAMSIZE=${BUCKET_RAMSIZE:=100}
BUCKET_PRIORITY=${BUCKET_PRIORITY:=low}
BUCKET_TYPE=${BUCKET_TYPE:=couchbase}
BUCKET_REPLICA=${BUCKET_REPLICA:=1}
BUCKET_EVICTION_POLICY=${BUCKET_EVICTION_POLICY:=valueOnly}
BUCKET_COMPRESSION=${BUCKET_COMPRESSION:=off}
BUCKET_MAX_TTL=${BUCKET_MAX_TTL:=0}
ENABLE_FLUSH=${ENABLE_FLUSH:=0} 
RBAC_USERNAME=${RBAC_USERNAME:=$BUCKET_USERNAME}
RBAC_PASSWORD=${RBAC_PASSWORD:=$BUCKET_PASSWORD}
RBAC_ROLES=${RBAC_ROLES:='admin'}

COMPACTION_DB_PERCENTAGE=${COMPACTION_DB_PERCENTAGE:=30}
COMPACTION_VIEW_PERCENTAGE=${COMPACTION_VIEW_PERCENTAGE:=30}
COMPACTION_GSI_INTERVAL=${COMPACTION_GSI_INTERVAL:=Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday}
GSI_COMPACTION_MODE=${GSI_COMPACTION_MODE:="circular"}

AUTO_FAILOVER_TIMEOUT=${AUTO_FAILOVER_TIMEOUT:=120}
ENABLE_AUTO_FAILOVER=${ENABLE_AUTO_FAILOVER:=1}
ENABLE_EMAIL_ALERT=${ENABLE_EMAIL_ALERT:=0}
EMAIL_RECIPIENTS=${EMAIL_RECIPIENTS:=""}
EMAIL_SENDER=${EMAIL_SENDER}
EMAIL_USER=${EMAIL_USER}
EMAIL_PASSWORD=${EMAIL_PASSWORD}
EMAIL_HOST=${EMAIL_HOST}
EMAIL_PORT=${EMAIL_PORT}
EMAIL_ENCRYPT=${EMAIL_ENCRYPT:=0}

DO_REBALANCE=${DO_REBALANCE:='0'}

sleep 2
echo ' '
printf 'Waiting for Couchbase Server to start'
until $(curl --output /dev/null --silent --head --fail -u $CLUSTER_USERNAME:$CLUSTER_PASSWORD http://localhost:8091/pools); do
  printf .
  sleep 1
done

echo ' '
echo Couchbase Server has started
echo Starting configuration for $NODE_TYPE node

echo Configuring Individual Node Settings
/opt/couchbase/bin/couchbase-cli node-init \
  --cluster localhost:8091 \
  --username=$CLUSTER_USERNAME \
  --password=$CLUSTER_PASSWORD \
  --node-init-data-path=$NODE_INIT_DATA_PATH \
  --node-init-index-path=$NODE_INIT_INDEX_PATH \
  --node-init-hostname=$NODE_INIT_HOSTNAME \
> /dev/null

if [[ "${NODE_TYPE}" == "INITIAL" ]]; then
  # configure master node
  echo Configuring Initial Cluster Node
  CLUSTERID="localhost:8091"
  CMD="/opt/couchbase/bin/couchbase-cli cluster-init"
  CMD="$CMD --cluster $CLUSTERID"
  CMD="$CMD --cluster-username $CLUSTER_USERNAME"
  CMD="$CMD --cluster-password $CLUSTER_PASSWORD"
  CMD="$CMD --cluster-ramsize $CLUSTER_RAMSIZE"

  # is the index service going to be running?
  if [[ $SERVICES == *"index"* ]]; then
    CMD="$CMD --index-storage-setting $INDEX_STORAGE_SETTING"
    CMD="$CMD --cluster-index-ramsize $CLUSTER_INDEX_RAMSIZE"
  fi
  # is the fts service going to be running?
  if [[ $SERVICES == *"fts"* ]]; then
    CMD="$CMD --cluster-fts-ramsize $CLUSTER_FTS_RAMSIZE"
  fi
  # is the eventing service going to be running?
  if [[ $SERVICES == *"eventing"* ]]; then
    CMD="$CMD --cluster-eventing-ramsize $CLUSTER_EVENTING_RAMSIZE"
  fi
  # is the analytics service going to be running?
  if [[ $SERVICES == *"analytics"* ]]; then
    CMD="$CMD --cluster-analytics-ramsize $CLUSTER_ANALYTICS_RAMSIZE"
  fi
  CMD="$CMD --services=$SERVICES"
  CMD="$CMD > /dev/null"
  eval $CMD

  echo Setting the Cluster Name
  /opt/couchbase/bin/couchbase-cli setting-cluster \
    --cluster  $CLUSTERID \
    --username $CLUSTER_USERNAME \
    --password $CLUSTER_PASSWORD \
    --cluster-name "$(echo $CLUSTER_NAME)" \
  > /dev/null

  echo Configuring Auto Failover Settings
  /opt/couchbase/bin/couchbase-cli setting-autofailover \
    --cluster  $CLUSTERID \
    --username $CLUSTER_USERNAME \
    --password $CLUSTER_PASSWORD \
    --auto-failover-timeout $AUTO_FAILOVER_TIMEOUT \
    --enable-auto-failover $ENABLE_AUTO_FAILOVER \
  > /dev/null

  ######### BUCKET CREATION STEPS #######
  # create the bucket
  if [ -z ${BUCKET+x} ]; then
    echo "no bucket to create"
  else
    echo Creating $BUCKET bucket
    /opt/couchbase/bin/couchbase-cli bucket-create \
      --cluster localhost:8091 \
      --username $CLUSTER_USERNAME \
      --password $CLUSTER_PASSWORD \
      --bucket $BUCKET \
      --bucket-ramsize $BUCKET_RAMSIZE \
      --bucket-type $BUCKET_TYPE \
      --bucket-priority $BUCKET_PRIORITY \
      --enable-index-replica $ENABLE_INDEX_REPLICA \
      --enable-flush $ENABLE_FLUSH \
      --bucket-replica $BUCKET_REPLICA \
      --bucket-eviction-policy $BUCKET_EVICTION_POLICY \
      --compression-mode $BUCKET_COMPRESSION \
      --max-ttl $BUCKET_MAX_TTL \
      --wait \
    > /dev/null

    # rbac user
    echo Creating RBAC user $RBAC_USERNAME
    /opt/couchbase/bin/couchbase-cli user-manage \
      --cluster localhost:8091 \
      --username $CLUSTER_USERNAME \
      --password $CLUSTER_PASSWORD \
      --set \
      --rbac-username $RBAC_USERNAME \
      --rbac-password $RBAC_PASSWORD \
      --roles $RBAC_ROLES \
      --auth-domain local \
    > /dev/null
  fi


echo  /opt/couchbase/bin/couchbase-cli user-manage \
      --cluster localhost:8091 \
      --username $CLUSTER_USERNAME \
      --password $CLUSTER_PASSWORD \
      --set \
      --rbac-username $SYNCGATEWAY_SVC_ACCT \
      --rbac-password $SYNCGATEWAY_PASSWORD \
      --roles $SYNCGATEWAY_ROLES \
      --auth-domain local

  if [ -z ${SYNCGATEWAY_SVC_ACCT+x} ]; then
    echo No SyncGateway Account
  else
   # sync gateway svc account
    echo Creating Sync Gateway user $SYNCGATEWAY_SVC_ACCT
    /opt/couchbase/bin/couchbase-cli user-manage \
      --cluster localhost:8091 \
      --username $CLUSTER_USERNAME \
      --password $CLUSTER_PASSWORD \
      --set \
      --rbac-username $SYNCGATEWAY_SVC_ACCT \
      --rbac-password $SYNCGATEWAY_PASSWORD \
      --roles $SYNCGATEWAY_ROLES \
      --auth-domain local \
    > /dev/null    
  fi

  # setting alerts
  echo Configuring Alert Settings
  if [ -z ${ENABLE_EMAIL_ALERT+x} ]; then
    ENABLE_EMAIL_ALERT=0;
  fi
  CMD="/opt/couchbase/bin/couchbase-cli setting-alert"
  CMD="$CMD --cluster localhost:8091"
  CMD="$CMD --username=$CLUSTER_USERNAME"
  CMD="$CMD --password=$CLUSTER_PASSWORD"
  CMD="$CMD --enable-email-alert=$ENABLE_EMAIL_ALERT"
  if [[ "${ENABLE_EMAIL_ALERT}" == "1" ]]; then
    CMD="$CMD --email-recipients=$EMAIL_RECIPIENTS"
    CMD="$CMD --email-sender=$EMAIL_SENDER"
    CMD="$CMD --email-user=$EMAIL_USER"
    CMD="$CMD --email-password=$EMAIL_PASSWORD"
    CMD="$CMD --email-host=$EMAIL_HOST"
    CMD="$CMD --email-port=$EMAIL_PORT"
    CMD="$CMD --enable-email-encrypt=$EMAIL_ENCRYPT"
    CMD="$CMD --alert-auto-failover-node"
    CMD="$CMD --alert-auto-failover-max-reached"
    CMD="$CMD --alert-auto-failover-node-down"
    CMD="$CMD --alert-auto-failover-cluster-small"
    CMD="$CMD --alert-auto-failover-disabled"
    CMD="$CMD --alert-ip-changed"
    CMD="$CMD --alert-disk-space"
    CMD="$CMD --alert-meta-overhead"
    CMD="$CMD --alert-meta-oom"
    CMD="$CMD --alert-write-failed"
    CMD="$CMD --alert-audit-msg-dropped"
  fi
  CMD="$CMD > /dev/null"
  eval $CMD

  # compaction settings
  echo Configuring Compaction Settings
  CMD="/opt/couchbase/bin/couchbase-cli setting-compaction"
  CMD="$CMD --cluster localhost:8091"
  CMD="$CMD --username=$CLUSTER_USERNAME"
  CMD="$CMD --password=$CLUSTER_PASSWORD"
  CMD="$CMD --compaction-db-percentage=$COMPACTION_DB_PERCENTAGE"
  CMD="$CMD --compaction-view-percentage=$COMPACTION_VIEW_PERCENTAGE"
  if [ -z ${COMPACTION_PERIOD_FROM+x} ]; then
    if [ -z ${COMPACTION_PERIOD_TO+x} ]; then
      CMD="$CMD --compaction-period-from=$COMPACTION_PERIOD_FROM"
      CMD="$CMD --compaction-period-to=$COMPACTION_PERIOD_TO"
      CMD="$CMD --enable-compaction-parallel=${ENABLE_COMPACTION_PARALLEL:=0}"
    fi
  fi

  ## add gsi compaction settings
  if [[ $(/opt/couchbase/bin/couchbase-server --version | grep -o "EE") == "EE" ]]; then
    CMD="$CMD --gsi-compaction-mode=$GSI_COMPACTION_MODE"
    if [[ "${GSI_COMPACTION_MODE}" == "append" ]]; then
      CMD="$CMD --compaction-gsi-percentage=${COMPACTION_GSI_PERCENTAGE:=30}"
    fi
    if [[ "$GSI_COMPACTION_MODE" == "circular" ]]; then
      CMD="$CMD --compaction-gsi-interval=$COMPACTION_GSI_INTERVAL"
      if [ -z ${COMPACTION_PERIOD_FROM+x} ]; then
        if [ -z ${COMPACTION_PERIOD_TO+x} ]; then
          CMD="$CMD --compaction-gsi-period-from=$COMPACTION_GSI_PERIOD_FROM"
          CMD="$CMD --compaction-gsi-period-to=$COMPACTION_GSI_PERIOD_TO"
        fi
      fi
    fi
  fi
  CMD="$CMD > /dev/null"
  eval $CMD

  # sample buckets
  if [ -n "$SAMPLE_BUCKETS" ]; then
    # loop over the comma-delimited list of sample buckets i.e. beer-sample,travel-sample
    for SAMPLE in $(echo $SAMPLE_BUCKETS | sed "s/,/ /g")
    do
      # load the sample documents into the bucket
      echo Loading $SAMPLE bucket
      curl -X POST -u $CLUSTER_USERNAME:$CLUSTER_PASSWORD http://localhost:8091/sampleBuckets/install -d ["\""$SAMPLE"\""]  
      > /dev/null 2>&1
    done
  fi

else

  echo Waiting for $CLUSTER_HOST to become available
  until $(curl --output /dev/null --silent --head --fail -u $CLUSTER_USERNAME:$CLUSTER_PASSWORD http://${CLUSTER_HOST}:8091/pools); do
    printf .
    sleep 1
   done

  ####Configuration for a new node to an existing cluster#################
  echo ' '
  echo Adding new Node to the cluster at $CLUSTER_HOST
  #sleep 30 #HACK to wait for the initial node to get configured first and then start the configuration process
  /opt/couchbase/bin/couchbase-cli server-add \
    --cluster couchbase://$(getent hosts $CLUSTER_HOST | awk '{ print $1 }') \
    --username=$CLUSTER_USERNAME \
    --password=$CLUSTER_PASSWORD \
    --server-add="http://$(getent hosts $HOSTNAME | awk '{ print $1 }'):8091" \
    --server-add-username=$CLUSTER_USERNAME \
    --server-add-password=$CLUSTER_PASSWORD \
    --services=$SERVICES  \
  > /dev/null 2>&1

  if [[ "${DO_REBALANCE}" == "1" ]]; then
    echo Rebalancing Cluster
    if (/opt/couchbase/bin/couchbase-cli rebalance-status --cluster localhost:8091 --username $CLUSTER_USERNAME --password  $CLUSTER_PASSWORD | grep -q running) then
      echo Only one rebalance operation can be done at a time, waiting for the current rebalance to complete
      until $(couchbase-cli rebalance-status --cluster localhost:8091 --username $CLUSTER_USERNAME --password $CLUSTER_PASSWORD | grep -q notRunning); do
        echo .
        sleep 5
      done
    fi
    /opt/couchbase/bin/couchbase-cli rebalance \
      --cluster localhost:8091 \
      --username=$CLUSTER_USERNAME \
      --password=$CLUSTER_PASSWORD \
    > /dev/null
  fi
fi

#Setup for alternative addresses and ports
#couchbase-cli setting-alternate-address -c localhost:8091 --username Administrator \
#   --password password --set --node localhost --hostname $EXTERNAL_HOSTNAME \
#   --ports mgmt=1100,capi=2000,capiSSL=3000

echo The new $NODE_TYPE node has been successfully configured

