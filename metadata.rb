name             "openstack-common"
maintainer       "Jay Pipes"
maintainer_email "jaypipes@gmail.com"
license          "Apache 2.0"
description      "Common OpenStack attributes, libraries and recipes."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.7"

recipe           "opentack-common", "Execute common recipes"

%w{ ubuntu fedora redhat centos }.each do |os|
  supports os
end

depends          "apt"
depends          "database"
supports         "ubuntu"
