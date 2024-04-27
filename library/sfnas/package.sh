#!/bin/bash

set -x;

builder=vapundevrhel7bld.vxindia.veritas.com
workspace=/lhome/abhijith/workspace/sfnas/
ssh_builder="ssh abhijith@${builder}"

build_area="${workspace}/build-rhel7"

echo "Build dir contents before running make package..."
${ssh_builder} "ls -lrt ${build_area}"

echo ""
echo "Capturing build environment"
${ssh_builder} "env"
echo ""

echo ""
echo "Running make package for sfnas rhel7"
${ssh_builder} "cd ${build_area}; time make VERBOSE=1 package"
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
