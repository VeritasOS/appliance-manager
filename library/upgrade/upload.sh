#!/bin/bash
. $(dirname $0)/../store/store.sh

mgmt_server=$(jq -r .cluster_setting.management_server.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
if [ "${mgmt_server}" == "" ]; then
    echo "Failed to get management server."
    exit 1
fi
mgmt_server_url=${mgmt_server}:14161

auth_token=$(get_cluster_auth_token)
cookie_file=$(get_cluster_cookie_file)
key="UPGRADE_RPM"
upgrade_rpm_path=$(get_key_value_from_store ${key})


curl -X POST \
  https://${mgmt_server_url}/api/appliance/v1.0/upgrade/upload \
  --cookie ${cookie_file} \
  -H "Authorization: Bearer ${auth_token}" \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F "upFile=@${upgrade_rpm_path}" \
  --insecure
