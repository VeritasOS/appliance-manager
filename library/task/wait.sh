#!/bin/bash

interval=60
total_wait_time=600

usage() {
    cat << EOF
Usage:
1. $(basename $0) -h
2. $(basename $0) [ -t <task-id> | -T <task-store-key> ] -c <cluster-name> -i <number> -w <number>

where,
    h   display this help usage.
    c   cluster
    i   seconds between checking task state. Default: ${interval}
    t   task id to wait on SUCCESS state, or until total wait time is reached when specified.
    T   Key name in store associated to a task ID.
    w   total wait time in seconds. Default: ${total_wait_time}
EOF
}

set -x
. $(dirname $0)/../store/store.sh

############################# main #############################
cluster=
while getopts 'hc:t:T:i:w:' OPTION; do
    case "$OPTION" in
    h)
        usage
        exit 0
        ;;
    c)
        cluster=${OPTARG}
        ;;
    i)
        interval=${OPTARG}
        ;;
    t)
        task_id=${OPTARG}
        ;;
    T)
        task_key=${OPTARG}
        ;;
    w)
        total_wait_time=${OPTARG}
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done

if [ "${task_id}" == "" ]; then
    if [ "${task_key}" == "" ]; then
        echo "Invalid script usage. Either a task ID or the key name of the task ID in store should be specified."
        exit 1
    fi
    task_id=$(get_key_value_from_store ${task_key})
fi

mgmt_server=$(jq -r .cluster_setting.management_server.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${cluster}.json)
if [ "${mgmt_server}" == "" ]; then
    echo "Failed to get management server."
    exit 1
fi
mgmt_server_url=${mgmt_server}:14161

auth_token=$(get_auth_token $cluster)
cookie_file=$(get_cookie_file_path $cluster)
wait_time=${total_wait_time}
while [ ${wait_time} -gt 0 ]; do
    wait_time=$((${wait_time} - ${interval}))
    resp=$(curl -X GET --cookie ${cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        --insecure \
        https://${mgmt_server_url}/api/appliance/v1.0/tasks/${task_id})
    state=$(echo $resp | jq -r .data.attributes.state)
    if [ "${state}" == "SUCCESS" ]; then
        echo "Task completed successfully."
        exit 0
    fi
    sleep ${interval}
done

echo "Task did not complete in specified wait time."
exit 1
