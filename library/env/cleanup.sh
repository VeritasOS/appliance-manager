#!/bin/bash

. $(dirname $0)/../store/store.sh
ENV_FILE=${ARTIFACTS_PATH}/env

if [ -f ${ENV_FILE} ]; then
    . ${ENV_FILE}
else
    myDir=/tmp
    ENV_FILE=${ARTIFACTS_PATH}/env
    COOKIE_FILE=${myDir}/cookie.txt
    TOKEN_FILE=${myDir}/token
    PARAMS_FILE=${myDir}/params.txt
fi

rm -f ${ENV_FILE} ${COOKIE_FILE} ${TOKEN_FILE} ${PARAMS_FILE}
