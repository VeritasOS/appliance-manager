#!/bin/bash

set -x

/usr/bin/docker run -dit --name=builder --dns=172.16.8.32 --dns-search=engba.veritas.com --add-host=appliancedashboard.engba.veritas.com:10.132.7.252 --privileged=true -d -v /home/abhijith/workspace/sfnas:/home/sfnas -v /storage:/storage -w /storage -v /var/run/docker.sock:/var/run/docker.sock artifactory-appliance.engba.veritas.com/dev_builder_rhel72
ret=$?
if [ ${ret} -eq "125" ]; then
	echo "Builder already exists."
	echo "Starting it..."
	/usr/bin/docker start builder
	ret=0
fi

/usr/bin/docker ps -a

exit ${ret}
