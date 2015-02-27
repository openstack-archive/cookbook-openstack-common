name             'openstack-common'
maintainer       'openstack-chef'
maintainer_email 'opscode-chef-openstack@googlegroups.com'
license          'Apache 2.0'
description      'Common OpenStack attributes, libraries and recipes.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '11.0.0'

recipe           'openstack-common', 'Installs/Configures common recipes'
recipe           'openstack-common::set_endpoints_by_interface', 'Set endpoints by interface'
recipe           'openstack-common::logging', 'Installs/Configures common logging'
recipe           'openstack-common::sysctl', 'Configures sysctl settings'
recipe           'openstack-common::openrc', 'Creates openrc file'

%w{ ubuntu suse redhat centos }.each do |os|
  supports os
end

depends 'apt', '~> 2.6.1'
depends 'database', '~> 4.0.2'
depends 'mysql', '~> 6.0.13'
depends 'yum', '~> 3.5.2'
depends 'yum-epel', '~> 0.6.0'
