#!/bin/bash

set -x;

ARTIFACTS_PATH=/storage/logs/artifacts
ENV_FILE=${ARTIFACTS_PATH}/env

. ${ENV_FILE}

# sudo docker exec builder /storage/patchman/replace.sh
# BUILDER=builder8
build_area=/storage/patchman/${BUILDER}

pushd ${build_area}

echo "Contents before replacing VRTSnas rpm in ISO"
ls -lrt

sudo docker exec ${BUILDER} sh -c "cd ${build_area}; time ./nbuso-sdk.sh nbfs-*.iso VRTSnas-*.x86_64.rpm storage"
if [ $? -ne 0 ]; then
	exit 1;
fi

echo "Contents after replacing VRTSnas rpm in ISO"
ls -lrt

iso_name=$(ls nbfs-*-test.iso)
mv ${iso_name} ../iso/${iso_name%-test.iso}.iso

exit 0;
