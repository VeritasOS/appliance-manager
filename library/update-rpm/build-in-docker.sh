#!/bin/bash

myDir=$(dirname $0)

set -x;

ARTIFACTS_PATH=/storage/logs/artifacts
ENV_FILE=${ARTIFACTS_PATH}/env
PARAMS_FILE=${ARTIFACTS_PATH}/params.txt

PM_LIBRARY=${PM_LIBRARY:-"$myDir/.."}
${PM_LIBRARY}/env/gen_env.sh

. ${ENV_FILE}
# BUILDTAG="3.1-20230515101857"

build_dir="/storage/patchman"

# sudo docker exec -it builder /storage/patchman/build.sh

echo "Contents before creating update RPM"
ls -lrt ${build_dir}/

sudo docker exec ${BUILDER} sh -c "cd ${build_dir}; time make patch_cs PRODUCT=nbfs BRANCH=main BUILDTAG=${BUILDTAG} UPGRADE_BUILDTAG=${BUILDTAG}"
if [ $? -ne 0 ]; then
	exit 1;
fi

echo "Contents after creating update RPM"
ls -lrt ${build_dir}/

timestamp=$(/usr/bin/date -u +%Y%m%d%H%M%S)
target_pkg_loc=${ARTIFACTS_PATH}/${timestamp}

mkdir -p ${target_pkg_loc}

pkg_path=$(ls $build_dir/*${BUILDTAG}*.rpm)
pkg_name=$(basename ${pkg_path})

mv ${pkg_path} ${target_pkg_loc}

cat >${PARAMS_FILE} <<EOF
UPGRADE_RPM_NAME=${pkg_name}
UPGRADE_RPM_PATH=${target_pkg_loc}/${pkg_name}
EOF

chmod a+rwx ${PARAMS_FILE}

exit 0;
