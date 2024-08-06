#!/bin/bash
. $(dirname $0)/../store/store.sh

wait_for_configure() {    
    first_node=$(jq -r '.nodes_setting[0].management_interface.fqdn_name' /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
    if [ "${first_node}" == "" ]; then
        echo "Failed to get the first node fqdn."
        exit 1
    fi
    first_node_url=${first_node}:8443
    
    node_auth_token=$(get_auth_token ${first_node})
    node_cookie_file=$(get_cookie_file_path ${first_node})

    wait_time=60
    while [ ${wait_time} ] >0; do
        sleep 1m
        echo "Checking configuration status every minute for next ${wait_time} minutes..."
        resp=$(curl -X GET --cookie ${node_cookie_file} \
            -H 'accept: application/json' \
            -H "Authorization: Bearer ${node_auth_token}" \
            --insecure \
            https://${first_node_url}/api/v1.0/ui/appliance/cpitasks)

        ret=$?
        if [ ${ret} -ne 0 ]; then
            echo "Failed to check cluster configuration status."
            # exit 1
        fi
        jq -n $resp
        # status=$(echo $resp | jq -r '.status')
        # if [ ${status} != "success" ]; then
        #     echo "Cluster configuration has failed."
        #     exit 1
        # fi
    done
}

wait_for_configure
