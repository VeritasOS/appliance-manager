#!/bin/bash
. $(dirname $0)/../store/store.sh

function exchange_certificates()
{
    mgmt_server=$(jq -r .cluster_setting.management_server.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)
    if [ "${mgmt_server}" == "" ]; then
        echo "Failed to get management server."
        exit 1
    fi
    mgmt_server_url=${mgmt_server}:14161

    dr_mgmt_server=$(jq -r .cluster_setting.management_server.fqdn_name /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)
    if [ "${dr_mgmt_server}" == "" ]; then
        echo "Failed to get DR management server."
        exit 1
    fi
    dr_mgmt_server_url=${dr_mgmt_server}:14161

    auth_token=$(get_cluster_auth_token)
    cookie_file=$(get_cluster_cookie_file)

    resp=$(curl --cookie ${cookie_file} -g -k --header "Authorization: Bearer ${auth_token}" https://${mgmt_server_url}/api/appliance/v1.0/certificates/appliance-webservice-ca)
    primaryCACertificate=$(echo "${resp}" | jq -r ".data.attributes.certificate")

    resp=$(curl --cookie ${cookie_file} -g -k --header "Authorization: Bearer ${auth_token}" https://${mgmt_server_url}/api/appliance/v1.0/certificates/appliance-webservice)
    primaryServerCertificate=$(echo "${resp}" | jq -r ".data.attributes.certificate")

    echo "Primary CA Certificate: ${primaryCACertificate}"
    echo
    echo "Primary server Certificate: ${primaryServerCertificate}"
    echo

    dr_auth_token=$(get_dr_cluster_auth_token)
    dr_cookie_file=$(get_dr_cluster_cookie_file)

    resp=$(curl --cookie ${dr_cookie_file} -g -k --header "Authorization: Bearer ${dr_auth_token}" https://${dr_mgmt_server_url}/api/appliance/v1.0/certificates/appliance-webservice-ca)
    secondaryCACertificate=$(echo "${resp}" | jq -r ".data.attributes.certificate")

    resp=$(curl --cookie ${dr_cookie_file} -g -k --header "Authorization: Bearer ${dr_auth_token}" https://${dr_mgmt_server_url}/api/appliance/v1.0/certificates/appliance-webservice)
    secondaryServerCertificate=$(echo "${resp}" | jq -r ".data.attributes.certificate")

    echo "Secondary CA Certificate: ${secondaryCACertificate}"
    echo
    echo "Secondary server Certificate: ${secondaryServerCertificate}"
    echo

    targetConsoleIP=$(jq -r .cluster_setting.console_ip /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${DR_CLUSTER}.json)

    # Exchange CA and server certificate for both clusters
    authCertArgs="{
        \"type\": \"appliance-webservice\",
        \"purpose\": \"remote-cluster-trust-auth\",
        \"attributes\": {
            \"gateway\": \"${targetConsoleIP}\",
            \"caCertificate\": \"${secondaryCACertificate}\",
            \"certificate\": \"${secondaryServerCertificate}\"
        }
    }"
    resp=$(curl --cookie ${cookie_file} -g -k -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer ${auth_token}" -d "${authCertArgs}" https://${mgmt_server_url}/api/appliance/v1.0/certificates)
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to install certificates on ${CLUSTER}."
        exit 1
    fi
    task_id=$(echo $resp | jq -r '.taskId')
    if [ "${task_id}" == "null" ]; then
        echo "Failed to install certificates on ${CLUSTER}."
        exit 1
    fi
    named_key=$(prepare_key ${CLUSTER} "EXCHANGE_CERTIFICATES_TASK_ID")
    put_key_value_to_store ${named_key} ${task_id}

    curl -X GET --cookie ${cookie_file} \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${auth_token}" \
        --insecure \
        https://${mgmt_server_url}/api/appliance/v1.0/tasks/${task_id}

    echo
    sleep 10

    sourceConsoleIP=$(jq -r .cluster_setting.console_ip /home/abhijith/workspace/nbfs/dr-setup/config/3.1/variables-${CLUSTER}.json)

    authCertArgs="{
        \"type\": \"appliance-webservice\",
        \"purpose\": \"remote-cluster-trust-auth\",
        \"attributes\": {
            \"gateway\": \"${sourceConsoleIP}\",
            \"caCertificate\": \"${primaryCACertificate}\",
            \"certificate\": \"${primaryServerCertificate}\"
        }
    }"
    resp=$(curl --cookie ${dr_cookie_file} -g -k -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer ${dr_auth_token}" -d "${authCertArgs}" https://${dr_mgmt_server_url}/api/appliance/v1.0/certificates)
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to install certificates on ${DR_CLUSTER}."
        exit 1
    fi
    dr_task_id=$(echo $resp | jq -r '.taskId')
    if [ "${dr_task_id}" == "null" ]; then
        echo "Failed to install certificates on ${DR_CLUSTER}."
        exit 1
    fi

    named_key=$(prepare_key ${DR_CLUSTER} "EXCHANGE_CERTIFICATES_TASK_ID")
    put_key_value_to_store ${named_key} ${dr_task_id}
}

# Exchange CA and server certificates between primary and secondary cluster
exchange_certificates
