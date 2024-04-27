#!/bin/bash
set -x;
ARTIFACTS_PATH=${ARTIFACTS_PATH:-/storage/logs/artifacts}
readonly STORE_FILE=${ARTIFACTS_PATH}/store

# get_key_value_from_store()
#   Gets specified key's value from store.
get_key_value_from_store() {
    key=${1:?}
    echo $(grep -P ${key}'=' ${STORE_FILE} | cut -d "=" -f 2)
}

# put_key_value_to_store() 
#   Saves key and value into store.
#   If key already exists in store, it'll be overwritten with new value.
put_key_value_to_store() {
    key=${1:?}
    value=${2:?}
    # Delete
    sed -i /^${key}/d ${STORE_FILE}
    cat >>${STORE_FILE} <<EOF
${key}=${value}
EOF
}

prepare_key() {
    name=${1:?}
    key=${2:?}
    echo "${name}_${key}"
}

#################### Commonly used functions ####################

get_auth_token() {
    name=${1:?}
    key="AUTH_TOKEN"
    named_key=$(prepare_key ${name} ${key})
    echo $(get_key_value_from_store ${named_key})
}

save_auth_token() {
    name=${1:?}
    value=${2:?}

    key="AUTH_TOKEN"
    named_key=$(prepare_key ${name} ${key})
    put_key_value_to_store ${named_key} ${value}
}

get_cookie_file_path() {
    name=${1:?}
    key="COOKIE_FILE"
    named_key=$(prepare_key ${name} ${key})
    echo $(get_key_value_from_store ${named_key})
}

save_cookie_file_path() {
    name=${1:?}
    value=${2:?}

    key="COOKIE_FILE"
    named_key=$(prepare_key ${name} ${key})
    put_key_value_to_store ${named_key} ${value}
}

#################### CLUSTER ####################
get_cluster_auth_token() {
    echo $(get_auth_token ${CLUSTER})
}

get_cluster_cookie_file() {
    echo $(get_cookie_file_path ${CLUSTER})
}

#################### DR CLUSTER ####################
get_dr_cluster_auth_token() {
    echo $(get_auth_token ${DR_CLUSTER})
}

get_dr_cluster_cookie_file() {
    echo $(get_cookie_file_path ${DR_CLUSTER})
}


