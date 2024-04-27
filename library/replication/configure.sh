#!/bin/bash
. $(dirname $0)/../store/store.sh

# WORKING via Swagger on NBFS 3.1:
#
# curl -X 'POST' \
#   'https://lagoscl02mgmt.engba.veritas.com:14161/api/appliance/v1.0/disaster-recovery' \
#   -H 'accept: application/json' \
#   -H "Authorization: Bearer $token"
#   -H 'Content-Type: application/json' \
#   -d '{
#   "targetManagementFqdn": "capetowncl02mgmt.engba.veritas.com",
#   "targetConsoleIP": "10.84.147.122",
#   "sourceReplicationParams": {
#     "ipAddress": "10.84.145.41"
#   },
#   "sourceHeartbeatParams": {
#     "ipAddress": "10.84.147.173"
#   },
#   "targetReplicationParams": {
#     "ipAddress": "10.84.147.120"
#   },
#   "targetHeartbeatParams": {
#     "ipAddress": "10.84.147.121"
#   },
#   "targetStorageServerCredentials": {
#     "userName": "admin_user",
#     "password": "P@ssw0rd@1234"
#   },
#   "useSameNBUPrimaryVIP": true
# }'

# Response body
# Download
# {
#   "taskId": "88547230-bbe3-11ee-9bdd-0757ed2783bf",
#   "message": "Configure NetBackup Primary service replication"
# }

configure()
{
    username=$(jq -r .admin_user /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
    password=$(jq -r .admin_password /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
    mgmt_server=$(jq -r .cluster_setting.management_server.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
    heartbeat_ip=$(jq -r .cluster_setting.heartbeat_ip /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
    replication_ip=$(jq -r .cluster_setting.replication_ip /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)

    dr_username=$(jq -r .admin_user /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)
    dr_password=$(jq -r .admin_password /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)
    dr_mgmt_server=$(jq -r .cluster_setting.management_server.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)
    dr_console_ip=$(jq -r .cluster_setting.console_ip /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)
    dr_heartbeat_ip=$(jq -r .cluster_setting.heartbeat_ip /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)
    dr_replication_ip=$(jq -r .cluster_setting.replication_ip /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)


    # cat >${REPLICATION_PARAMS_FILE} <<EOF
    replication_params=$(cat <<EOF
{
    "targetManagementFqdn": "${dr_mgmt_server}",
    "targetConsoleIP": "${dr_console_ip}",
    "sourceReplicationParams": {
        "ipAddress": "${replication_ip}"
    },
    "sourceHeartbeatParams": {
        "ipAddress": "${heartbeat_ip}"
    },
    "targetReplicationParams": {
        "ipAddress": "${dr_replication_ip}"
    },
    "targetHeartbeatParams": {
        "ipAddress": "${dr_heartbeat_ip}"
    },
    "targetStorageServerCredentials": {
        "userName": "${dr_username}",
        "password": "${dr_password}"
    },
    "useSameNBUPrimaryVIP": true
}
EOF
)

    auth_token=$(get_cluster_auth_token)
    cookie_file=$(get_cluster_cookie_file)
    mgmt_server_url="${mgmt_server}:14161"

    resp=$(curl -X POST --cookie ${cookie_file} \
        -H 'Content-Type: application/json' \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        -d "${replication_params}" \
        --insecure \
        https://${mgmt_server_url}/api/appliance/v1.0/disaster-recovery)

    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to configure replication."
        exit 1
    fi
    task_id=$(echo $resp | jq -r '.taskId')
    if [ "${task_id}" == "null" ]; then
        echo "Failed to configure replication."
        exit 1
    fi

    curl -X GET --cookie ${cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        --insecure \
        https://${mgmt_server_url}/api/appliance/v1.0/disaster-recovery

    curl -X GET --cookie ${cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        --insecure \
        https://${mgmt_server_url}/api/appliance/v1.0/tasks/${task_id}
}

configure
