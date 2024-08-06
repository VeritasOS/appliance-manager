#!/bin/bash

set -x;

ARTIFACTS_PATH=/storage/logs/artifacts
ENV_FILE=${ARTIFACTS_PATH}/env

# INFO: ENV_FILE should be created before calling this script.
#   Otherwise an ENV_FILE with default values would be created.
if [ ! -f ${ENV_FILE} ]; then
    # Defaults
    # echo """
# """  >${ENV_FILE}
    cat >${ENV_FILE} <<EOF
USER=admin_user
PASSWORD=P@ssw0rd@1234
MGMTSERVER=lagoscl01mgmt.engba.veritas.com:14161
BUILDTAG="3.1-20230515101857"
EOF

    chmod a+rwx ${ENV_FILE}
fi
