#!/bin/bash

set -x;

builder=vapundevrhel7bld.vxindia.veritas.com
workspace=/lhome/abhijith/workspace/sfnas/
ssh_builder="ssh abhijith@${builder}"

build_area="${workspace}/build-rhel7"

# ${ssh_builder} "rm -rf ${build_area};"
${ssh_builder} "mkdir -p ${build_area};"

echo "Build dir contents before running cmake..."
${ssh_builder} "ls -lrt ${build_area}"

echo "Running cmake to build rhel7 package"

${ssh_builder} "cd ${build_area}; /snas/user/cmake/bin/cmake -DBUILD_CONFIG=rhel7_5550 -DCMAKE_BUILD_TYPE=Release ${workspace}"
if [ $? -ne 0 ]; then
  echo "Failed to cmake sfnas"
  exit 1
fi

echo "Build dir contents after running cmake..."
${ssh_builder} "ls -lrt ${build_area}"

exit 0
