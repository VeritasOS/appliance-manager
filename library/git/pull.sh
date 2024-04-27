#!/bin/bash

set -x;

builder=vapundevrhel7bld.vxindia.veritas.com
workspace=/lhome/abhijith/workspace/sfnas/
ssh_builder="ssh abhijith@${builder}"

#git branch -l
myBranch=$(${ssh_builder} "cd ${workspace}; git branch --list | grep \"*\"")
#ssh abhijith@${builder} "cd ${workspace}; git branch --list | grep "*"")
echo "Updating current branch ${myBranch}..."

scp ~/.tok-git-vault abhijith@${builder}:/lhome/abhijith/.tok-git-vault

${ssh_builder} "cd ${workspace}; /usr/local/bin/git pull -r"
if [ $? -ne 0 ]; then
  echo "Failed to update branch."
  exit 1
fi

# Just cleanup deleted branches while we update!
${ssh_builder} "cd ${workspace}; git fetch -p"

# Log the commit so that we know which one has picked up!
${ssh_builder} "cd ${workspace}; git log -1"

exit 0
