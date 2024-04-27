#!/bin/bash

set -x;

ARTIFACTS_PATH=/storage/logs/artifacts
ENV_FILE=${ARTIFACTS_PATH}/env

# INFO: ENV_FILE should be created before calling this script.
#   Otherwise an ENV_FILE with default values would be created.
if [ ! -f ${ENV_FILE} ]; then
    echo "${ENV_FILE} doesn't exist."
    exit 1;
fi

. ${ENV_FILE}
