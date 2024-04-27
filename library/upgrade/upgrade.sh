#!/bin/bash
. $(dirname $0)/../store/store.sh

set -x;

ARTIFACTS_PATH=/storage/logs/artifacts
UPGRADE_PARAMS_FILE=${ARTIFACTS_PATH}/upgrade-params.json

upgrade()
{
# From UI:
# Request URL:
# https://lagoscl01mgmt.engba.veritas.com:14161/api/v1.0/upgrade/patches/VRTSnbfs_app_update-3.2-20240129005634.x86_64.rpm
# Request Method:
# POST
# {
#     "question_answer": {
#         "upgrade_type": "parallel"
#     }
# }


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

    upgrade_params='{
        "question_answer": {
            "upgrade_type": "parallel"
        }
    }'

    resp=$(curl -X POST --cookie ${cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        -d "${upgrade_params}" \
        --insecure \
        https://${mgmt_server_url}/api/v1.0/upgrade/patches/${upgrade_rpm_name})
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to run upgrade.";
	    exit 1;
    fi
    echo $resp
}


upgrade



# Request URL:
# GET https://lagoscl01mgmt.engba.veritas.com:14161/api/v1.0/upgrade/patches/progress
# GET https://lagoscl01mgmt.engba.veritas.com:14161/api/v1.0/upgrade/patches/progress/state
