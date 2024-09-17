#!/bin/bash

set -x;

ssh_user=${SSH_USER:-abhijith}
builder=${BUILD_SYSTEM:-vapundevrhel7bld.vxindia.veritas.com}
workspace=${WORKSPACE:-'~/workspace/sfnas'}

ssh_builder="ssh ${ssh_user}@${builder}"

build_area="${workspace}/build-rhel7"

echo "Build dir contents before running make package..."
${ssh_builder} "ls -lrt ${build_area}"

echo ""
echo "Capturing build environment"
${ssh_builder} "env"
echo ""

echo ""
echo "Running make package for sfnas rhel7"
${ssh_builder} "cd ${build_area}; make -j 1 VERBOSE=1 package" &> logs;
if [ $? -ne 0 ]; then
  echo "Failed to cmake sfnas"
  exit 1
fi
echo ""


echo ""
echo "Build dir contents after running make package..."
${ssh_builder} "ls -lrt ${build_area}"
echo ""

exit 0
