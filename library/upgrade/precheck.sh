#!/bin/bash
. $(dirname $0)/../store/store.sh

precheck()
{
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
    upgrade_rpm_name=$(basename ${upgrade_rpm_path})

    # NOTE: There are two APIs, but only second one below returns task ID. 
    # 1. API with RPM name at the end doesn't return task ID: https://capetowncl01mgmt.engba.veritas.com:14161/api/v1.0/upgrade/patches/pre-check/VRTSnbfs_app_update-3.1-20230515101857.x86_64.rpm
    # 2. Returns task ID: https://capetowncl01mgmt.engba.veritas.com:14161/api/v1.0/upgrade//VRTSnbfs_app_update-3.1-20230515101857.x86_64.rpm/pre-check
    resp=$(curl -X POST --cookie ${cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        --insecure \
        https://${mgmt_server_url}/api/appliance/v1.0/upgrade/${upgrade_rpm_name}/pre-check)
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to run precheck.";
	    exit 1;
    fi
    task_id=$(echo $resp | jq -r '.taskId')
    if [ "${task_id}" == "null" ]; then
        echo "Failed to run precheck on ${CLUSTER}."
        exit 1
    fi
    named_key=$(prepare_key ${CLUSTER} "UPGRADE_PRECHECK_TASK_ID")
    put_key_value_to_store ${named_key} ${task_id}
}


precheck
