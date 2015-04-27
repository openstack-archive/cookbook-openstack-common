#!/bin/bash -x
## This script is for installing all the needed packages on trusty to run the chef tests with 'chef exec rake'

# install needed packages
sudo apt-get -y install build-essential liblzma-dev zlib1g-dev

# install chefdk
chefdk=chefdk_0.4.0-1_amd64.deb
wget -nv -t 3 https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/$chefdk
sudo dpkg -i $chefdk

## workaround to fix redhat fauxhai permission issue (can be removed with fauxhai > 2.3 in chefdk)
sudo chef exec ruby -e "require 'fauxhai'; Fauxhai.mock(platform:'redhat', version:'7.1')"
