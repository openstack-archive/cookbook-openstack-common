name             'openstack-common'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Common OpenStack attributes, libraries and recipes.'
version          '18.0.0'

recipe 'openstack-common', 'Installs/Configures common recipes'
recipe 'openstack-common::logging', 'Installs/Configures common logging'
recipe 'openstack-common::sysctl', 'Configures sysctl settings'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'etcd', '~> 5.5'
depends 'mariadb', '~> 1.5'
depends 'memcached', '~> 4.1'
depends 'mysql', '~> 8.2'
depends 'selinux'
depends 'yum-epel'

issues_url 'https://launchpad.net/openstack-chef'
source_url 'https://opendev.org/openstack/cookbook-openstack-common'
chef_version '>= 14.0'
