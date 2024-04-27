#!/bin/bash

usage() {
    cat << EOF
Usage: $(basename $0) [-h] [-c <cluster-name> -n [-f] [-g] [-r]]

where,
    h   display this help usage.
    c   specify cluster name argument.
    n   indicates action on a node of the cluster instead of cluster.
    f   fetch new token even if one was fetched earlier.
    g   get already fetched token if present. Else get new one.
    r   remove existing token information
EOF
}

set -x;

. $(dirname $0)/../store/store.sh


_get_cluster_token()
{
    local cluster=${1:?}
    # echo "Cluster: ${cluster}..."

    username=$(jq -r .admin_user /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${cluster}.json)
    password=$(jq -r .admin_password /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${cluster}.json)
    mgmt_server=$(jq -r .cluster_setting.management_server.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${cluster}.json)
    if [ "${mgmt_server}" == "" ]; then
        echo "Failed to get management server.";
        exit 1;
    fi
    mgmt_server_url=${mgmt_server}:14161

    curl -X 'POST' --cookie-jar ${COOKIE_FILE} \
    -d "username=${username}&password=${password}" https://${mgmt_server_url}/api/rest/authenticate \
    -H 'accept: application/json' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --insecure > ${TOKEN_FILE}
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to get token.";
	    exit 1;
    fi
    chmod a+rwx ${COOKIE_FILE} ${TOKEN_FILE};

    sed -i /^${cluster}_AUTH_TOKEN/d ${STORE_FILE}
    sed -i /^${cluster}_COOKIE_FILE/d ${STORE_FILE}
    cat >>${STORE_FILE} <<EOF
${cluster}_AUTH_TOKEN=$(jq -r .token ${TOKEN_FILE})
${cluster}_COOKIE_FILE=${COOKIE_FILE}
EOF
}


_get_node_token_of_cluster()
{
    local cluster=${1:?}
    # echo "Cluster: ${node}..."

    username="root"
    password="P@ssw0rd"
    node_name=$(jq -r '.nodes_setting[0].management_interface.fqdn_name' /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${cluster}.json)
    if [ ${node_name} == "" ]; then
        echo "Failed to get management server.";
        exit 1;
    fi
    node_url=${node_name}:8443

    cookie_file=${ARTIFACTS_PATH}/${cluster}/${node_name}-cookie.txt
    token_file=${ARTIFACTS_PATH}/${cluster}/${node_name}-token

    curl -X 'POST' --cookie-jar ${cookie_file} \
    -d "username=${username}&password=${password}" https://${node_url}/api/rest/authenticate \
    -H 'accept: application/json' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --insecure > ${token_file}
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to get token.";
	    exit 1;
    fi
    chmod a+rwx ${cookie_file} ${token_file};

    save_auth_token ${node_name} $(jq -r .token ${token_file})
    save_cookie_file_path ${node_name} ${cookie_file}
}

get_cluster_token()
{
    cluster=${1:?}
    if [ ! -f ${TOKEN_FILE} ]; then
        _get_cluster_token $cluster;
    fi
    jq -r .token ${TOKEN_FILE};
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to get token.";
        echo "Contents of token file: "
        cat "${TOKEN_FILE}";
	    exit 1;
    fi
}


get_node_token_of_cluster()
{
    cluster=${1:?}
    if [ ! -f ${TOKEN_FILE} ]; then
        _get_node_token_of_cluster $cluster;
    fi
    jq -r .token ${TOKEN_FILE};
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to get token.";
        echo "Contents of token file: "
        cat "${TOKEN_FILE}";
	    exit 1;
    fi
}

############################# main #############################
cluster=
while getopts 'hc:nfgr' OPTION; do
    case "$OPTION" in
        h)
            usage;
            exit 0;
            ;;
        c)
            cluster=${OPTARG};
            ;;
        n)
            node_name=$(jq -r .nodes_setting[0].management_interface.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${cluster}.json)
            ;;
        f)
            cmd="fetch";
            ;;
        g)
            cmd="get";
            ;;
        r)
            cmd="remove";
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

mkdir -p ${ARTIFACTS_PATH}/${cluster}/

if [ "${node_name}" != "" ]; then
    tnode="${node_name}-"
fi
COOKIE_FILE=${ARTIFACTS_PATH}/${cluster}/${tnode}cookie.txt
TOKEN_FILE=${ARTIFACTS_PATH}/${cluster}/${tnode}token

case "$cmd" in
    "fetch")
            echo "Fetching new token even if one already exists...";
            rm -rf ${COOKIE_FILE} ${TOKEN_FILE};
            if [ "${node_name}" == "" ]; then
                AUTH_TOKEN=$(get_cluster_token ${cluster})                
            else
                AUTH_TOKEN=$(get_node_token_of_cluster ${cluster})
            fi
            ;;
    "get")
            echo "Getting token from already fetched. If not, fetching new one...";
            if [ "${node_name}" == "" ]; then
                AUTH_TOKEN=$(get_cluster_token ${cluster})                
            else
                AUTH_TOKEN=$(get_node_token_of_cluster ${cluster})
            fi
            ;;
    "remove")
            echo "Removing token...";
            rm -rf ${COOKIE_FILE} ${TOKEN_FILE};
            ;;
esac
