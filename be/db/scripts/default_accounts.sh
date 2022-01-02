/opt/couchbase/bin/couchbase-cli user-manage \
--cluster http://localhost \
--username Administrator \
--password password \
--set \
--rbac-username default_sg_service \
--rbac-password password \
--rbac-name "Sync Gateway Service Account" \
--roles mobile_sync_gateway[*] \
--auth-domain local
