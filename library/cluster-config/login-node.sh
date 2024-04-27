#!/bin/bash

set -x;


myDir=$(dirname $0)
# echo "My location: $myDir"
ARTIFACTS_PATH=/storage/logs/artifacts
PARAMS_FILE=${ARTIFACTS_PATH}/params.txt

NODE_COOKIE_FILE=${ARTIFACTS_PATH}/node-cookie.txt
NODE_TOKEN_FILE=${ARTIFACTS_PATH}/node-token


_get_node_token()
{
    # https://lagoscl02n01.engba.veritas.com:8443/login
    # curl -X POST --cookie-jar /storage/logs/artifacts/node-cookie.txt -d 'username=root&password=P@ssw0rd' https://lagoscl02n01.engba.veritas.com:8443/login -H 'accept: application/json' -H 'Content-Type: application/x-www-form-urlencoded' --insecure


    PM_LIBRARY=${PM_LIBRARY:-"$myDir/.."}
    ${PM_LIBRARY}/env/gen_env.sh

    ENV_FILE=${ARTIFACTS_PATH}/env
    . ${ENV_FILE}

    default_user="root"
    default_password="P@ssw0rd"

    curl -X 'POST' --cookie-jar ${NODE_COOKIE_FILE} \
    -d "username=${default_user}&password=${default_password}" https://${FIRST_NODE}/api/rest/authenticate \
    -H 'accept: application/json' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --insecure > ${NODE_TOKEN_FILE}
    ret=$?
    if [ ${ret} -ne 0 ]; then
        echo "Failed to get token.";
	    exit 1;
    fi
    chmod a+rwx ${NODE_COOKIE_FILE} ${NODE_TOKEN_FILE};

    sed -i /^NODE_AUTH_TOKEN/d ${PARAMS_FILE}
    sed -i /^NODE_COOKIE_FILE/d ${PARAMS_FILE}
    cat >>${PARAMS_FILE} <<EOF
NODE_AUTH_TOKEN=$(get_node_token)
NODE_COOKIE_FILE=${NODE_COOKIE_FILE}
EOF

}

get_node_token()
{
    if [ ! -f ${NODE_TOKEN_FILE} ]; then
        _get_node_token;
    fi
    jq -r .token ${NODE_TOKEN_FILE};
}


############################# main #############################

while getopts 'cfgh' OPTION; do
    case "$OPTION" in
        c)
            echo "Removing token...";
            rm -rf ${NODE_COOKIE_FILE} ${NODE_TOKEN_FILE};
            ;;
        f)
            echo "Fetching new token even if one already exists...";
            rm -rf ${NODE_COOKIE_FILE} ${NODE_TOKEN_FILE};
            NODE_AUTH_TOKEN=$(get_node_token)
            ;;
        g)
            echo "Getting token from already fetched. If not, fetching new one...";
            NODE_AUTH_TOKEN=$(get_node_token)
            ;;
        h)
            echo -e ${USAGE_STR};
            ;;

        # ?)
        #     echo ${USAGE_STR}
        #     exit 1
        #     ;;
    esac
done


