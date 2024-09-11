#!/bin/bash

set -x;

update_build_area="/storage/patchman/build"

echo "Before copying RPM..."
ls -lrt ${update_build_area};

scp abhijith@vapundevrh8bld.vxindia.veritas.com:workspace/sfnas/rhel8/VRTSnas-*-RHEL8.x86_64.rpm ${update_build_area}
if [ $? -ne 0 ]; then
  echo "Failed to scp sfnas RPM"
  exit 1
fi

echo "After copying RPM..."
ls -lrt ${update_build_area};
