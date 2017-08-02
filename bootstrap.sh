#!/bin/bash -x
## This script is for installing all the needed packages on CentOS 7 and Ubuntu 16.04 to run the chef tests with 'chef exec rake'

if [ -f /usr/bin/yum ] ; then
  # install needed packages
  sudo yum clean all
  sudo yum -y groupinstall "Development Tools"
  sudo yum -y install xz-devel zlib-devel

  # uninstall requests from pip
  sudo pip uninstall requests -y || true

  # install chefdk
  chefdk=chefdk-1.5.0-1.el7.x86_64.rpm
  wget -nv -t 3 https://packages.chef.io/stable/el/7/$chefdk
  sudo yum -y install $chefdk
  rm $chefdk

  # explicitly disable selinux
  sudo /usr/sbin/setenforce 0

elif [ -f /usr/bin/apt-get ]; then

  # install needed packages
  sudo apt-get update
  sudo apt-get -y install build-essential liblzma-dev zlib1g-dev

  # install chefdk
  chefdk=chefdk_1.5.0-1_amd64.deb
  wget -nv -t 3 https://packages.chef.io/stable/ubuntu/16.04/$chefdk
  sudo dpkg -i $chefdk
  rm $chefdk

fi

if [ $(id -u) != 0 ]; then
  # preserve environment to keep ZUUL_* params
  export SUDO='sudo -E'
fi

# if we're in an integration gate, we're using OpenStack mirrors
if [ -f /etc/nodepool/provider ]; then
  source /etc/nodepool/provider
  NODEPOOL_MIRROR_HOST=${NODEPOOL_MIRROR_HOST:-mirror.$NODEPOOL_REGION.$NODEPOOL_CLOUD.openstack.org}
  NODEPOOL_MIRROR_HOST=$(echo $NODEPOOL_MIRROR_HOST|tr '[:upper:]' '[:lower:]')
  CENTOS_MIRROR_HOST=${NODEPOOL_MIRROR_HOST}
  UCA_MIRROR_HOST="${NODEPOOL_MIRROR_HOST}/ubuntu-cloud-archive"
  CEPH_MIRROR_HOST="${NODEPOOL_MIRROR_HOST}/ceph-deb-jewel"
else
  CENTOS_MIRROR_HOST='mirror.centos.org'
  UCA_MIRROR_HOST='ubuntu-cloud.archive.canonical.com/ubuntu'
  CEPH_MIRROR_HOST='download.ceph.com/debian-jewel'
fi

# The following will handle cross cookbook patch dependencies via the Depends-On in commit message

# ZUUL_CHANGES has a ^ separated list of patches, the last being the current patch.
# The Depends_On will add patches to the front of this list.
echo $ZUUL_CHANGES
# Convert string list to array
cookbooks=(${ZUUL_CHANGES//^/ })
# Remove the last one as it's the current cookbook
# TODO(MRV) At some point we could consider removing the gerrit-git-prep step from the rake job
# and also doing that patch clone with zuul-cloner.  After gerrit-git-prep is removed, need to
# remove this unset line and adjust the clone map to have the base patch put into the current dir.
unset cookbooks[${#cookbooks[@]}-1]

# Create clone map
cat > clonemap.yaml <<EOF
clonemap:
 - name: 'openstack/(.*)'
   dest: '\1'
EOF

# Create list of Depends-On cookbook names and update Berksfile entry for each
cookbook_projects=""
for cookbook_info in "${cookbooks[@]}"; do
  [[ $cookbook_info =~ openstack/([a-z-]*):.* ]]
  cookbook_name="${BASH_REMATCH[1]}"
  cookbook_projects+=" openstack/$cookbook_name"
  sed -i -e "s|github: [\"\']openstack/$cookbook_name[\"\']|path: '../$cookbook_name'|" Berksfile
done

# Allow the zuul cloner to pull down the necessary Depends-On patches
#
# also change ownership of .chef and workspace
if [ "$cookbook_projects" ]
then
  sudo -E /usr/zuul-env/bin/zuul-cloner \
    -m clonemap.yaml \
    --cache-dir /opt/git \
    --workspace /home/jenkins/workspace/ \
    git://git.openstack.org \
    $cookbook_projects && \
    sudo chown -R jenkins:jenkins /home/jenkins/workspace && \
    sudo mkdir -p /home/jenkins/.chef && \
    sudo chown -R jenkins:jenkins /home/jenkins/.chef
fi
