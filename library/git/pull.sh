#!/bin/bash

set -x;

ssh_user=${SSH_USER:-abhijith}
builder=${BUILD_SYSTEM:-vapundevrhel7bld.vxindia.veritas.com}
workspace=${WORKSPACE:-/lhome/${ssh_user}/workspace/sfnas/}

ssh_builder="ssh ${ssh_user}@${builder}"

# Depending on whether Appliance/Plugin Manager is running as a root or normal user, it'll switch to ssh_user, so that ssh commands can be run.
run_as_ssh_user()
{
  cmd=$1
  cur_user=$(id -un)
  if [ "root" == "${cur_user}" ]; then
    su -c "${ssh_builder} \"$cmd\"" -s /bin/bash ${ssh_user}
  else
    ${ssh_builder} "$cmd"
  fi
}

# Logging user under which service is being run just for debugging purpose!
echo "Local user..."
su -c "id; pwd" -s /bin/bash ${ssh_user}

cur_branch=$(run_as_ssh_user "cd ${workspace}; git branch --list | grep -F \\\"*\\\"")
cur_branch=${cur_branch##* }
git_branch=${GIT_BRANCH:-${cur_branch}}
if [ ${git_branch} != ${cur_branch} ]; then
  echo "Switching to branch ${git_branch}...";
  run_as_ssh_user "cd ${workspace}; git checkout ${git_branch}";
fi

echo "Updating branch ${git_branch}..."
su -c "scp ~/.tok-git-vault ${ssh_user}@${builder}:/lhome/${ssh_user}/.tok-git-vault" -s /bin/bash ${ssh_user}
run_as_ssh_user "cd ${workspace}; git pull -r"
if [ $? -ne 0 ]; then
  echo "Failed to update branch."
  exit 1
fi

# Just cleanup deleted branches while we update!
run_as_ssh_user "cd ${workspace}; git fetch -p"

# Log the git commit-id so that we know which one has picked up!
run_as_ssh_user "cd ${workspace}; git log -1"

exit 0
