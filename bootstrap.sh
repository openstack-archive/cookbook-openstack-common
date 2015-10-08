#!/bin/bash -x
## This script is for installing all the needed packages on trusty to run the chef tests with 'chef exec rake'

# install needed packages
sudo apt-get -y install build-essential liblzma-dev zlib1g-dev

# install chefdk
chefdk=chefdk_0.9.0-1_amd64.deb
wget -nv -t 3 https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/$chefdk
sudo dpkg -i $chefdk
rm $chefdk

## workaround to fix redhat fauxhai permission issue (can be removed with fauxhai > 2.3 in chefdk)
sudo chef exec ruby -e "require 'fauxhai'; Fauxhai.mock(platform:'redhat', version:'7.1')"

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
if [ "$cookbook_projects" ]
then
  sudo -E /usr/zuul-env/bin/zuul-cloner \
    -m clonemap.yaml \
    --cache-dir /opt/git \
    --workspace /home/jenkins/workspace/ \
    git://git.openstack.org \
    $cookbook_projects
fi
