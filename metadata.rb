name             'openstack-common'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Common OpenStack attributes, libraries and recipes.'
version          '19.0.0'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'etcd', '~> 5.6'
depends 'mariadb', '~> 3.1'
depends 'memcached', '~> 6.0'
depends 'selinux'
depends 'yum-epel'

issues_url 'https://launchpad.net/openstack-chef'
source_url 'https://opendev.org/openstack/cookbook-openstack-common'
chef_version '>= 15.0'
