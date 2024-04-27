#!/bin/bash
. $(dirname $0)/../store/store.sh

PM_LIBRARY=${PM_LIBRARY:-"$(dirname $0)/../"}
CLUSTER_CONFIG_FILE_PATH=${CLUSTER_CONFIG_FILE_PATH:-"${PM_LIBRARY}/cluster-config/config"}

configure()
{
    # https://lagoscl02n01.engba.veritas.com:8443/api/v1.0/ui/appliance/rescan
    # {"username":null,"password":null}

    # Request URL:
    # https://lagoscl02n01.engba.veritas.com:8443/api/v1.0/ui/appliance/configuration
    # Request Method:
    # PUT
    # Status Code:
    # 200 OK
    # Remote Address:
    # 10.84.150.173:8443

    # https://lagoscl02n01.engba.veritas.com:8443/api/v1.0/ui/appliance/factoryReset

# Request URL:
# https://lagoscl02n01:8443/api/v1.0/ui/appliance/cluster
# Request Method:
# POST
# Status Code:
# 200 OK

# check file: config/lagos_CLUSTER_CONFIG_PARAMS.json

# Response:
# {"message":"Cluster configuration initiated"}


    cluster_config_params_file_name=$(prepare_key ${CLUSTER} "CLUSTER_CONFIG_PARAMS_FILE")".json"

    cluster_config_params_file_path="${CLUSTER_CONFIG_FILE_PATH}/${cluster_config_params_file_name}"

    # jq -n ${params}    
    first_node=$(jq -r '.nodes_setting[0].management_interface.fqdn_name' /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
    if [ "${first_node}" == "" ]; then
        echo "Failed to get the first node fqdn."
        exit 1
    fi
    first_node_url=${first_node}:8443
    
    node_auth_token=$(get_auth_token ${first_node})
    node_cookie_file=$(get_cookie_file_path ${first_node})

        # -d "@${CLUSTER_CONFIG_PARAMS_FILE}" \
        # OR
        # -d "${cluster_config_params}" \


    resp=$(curl -X PUT --cookie ${node_cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${node_auth_token}" \
        -d '{"username":"root", "password":"P@ssw0rd"}' \
        --insecure \
        https://${first_node_url}/api/v1.0/ui/appliance/rescan)
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to trigger rescan.";
    fi
    sleep 1m
    
    resp=$(curl -X POST --cookie ${node_cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${node_auth_token}" \
        -d "@${cluster_config_params_file_path}" \
        --insecure \
        https://${first_node_url}/api/v1.0/ui/appliance/cluster)

    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to trigger cluster configuration.";
	    exit 1;
    fi
    status=$(echo $resp | jq -r '.status')
    if [ ${status} != "success" ]; then
        echo "Failed to configure cluster.";
        exit 1;
    fi
}


configure
