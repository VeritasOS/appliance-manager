#!/bin/bash
. $(dirname $0)/../store/store.sh

set -x


list()
{
    mgmt_server_url=$(get_management_server_url ${CLUSTER})
    auth_token=$(get_cluster_auth_token)
    cookie_file=$(get_cluster_cookie_file)
    upgrade_rpm_name=$(get_key_value_from_store "UPGRADE_RPM_NAME")

    resp=$(curl -X GET --cookie ${cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        --insecure \
        https://${mgmt_server_url}/api/appliance/v1.0/upgrade/patches/${upgrade_rpm_name})
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to list update packages.";
	    exit 1;
    fi
    echo $resp
}


list

# basename $(echo $(list) | jq -r .data[].links.self.href )
# Gives multiple packages --- package_loc=$(list | jq -r .data[].links.self.href)
# pkg_name=$(basename ${package_loc})

