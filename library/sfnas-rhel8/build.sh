#!/bin/bash

set -x;

ssh_user=${SSH_USER:-abhijith}
builder=${BUILD_SYSTEM:-vapundevrh8bld8.vxindia.veritas.com}
workspace=${WORKSPACE:-'~/workspace/sfnas'}

ssh_builder="ssh ${ssh_user}@${builder}"

build_area="${workspace}/rhel8"

# ${ssh_builder} "rm -rf ${build_area};"
${ssh_builder} "mkdir -p ${build_area};"
if [ $? -ne 0 ]; then
  echo "Failed to create build directory ${build_area}"
  exit 1
fi

echo "Build dir contents before running cmake..."
${ssh_builder} "ls -lrt ${build_area}"

echo "Running cmake to build rhel8 package"

${ssh_builder} "cd ${build_area}; cmake -DBUILD_CONFIG=rhel8_5550 -DCMAKE_BUILD_TYPE=Release ${workspace}"
if [ $? -ne 0 ]; then
  echo "Failed to cmake sfnas"
  exit 1
fi

echo "Build dir contents after running cmake..."
${ssh_builder} "ls -lrt ${build_area}"

exit 0
