name             'openstack-common'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Common OpenStack attributes, libraries and recipes.'
version          '20.0.0'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'etcd', '~> 7.0'
depends 'mariadb', '~> 5.0'
depends 'memcached', '~> 7.0'
depends 'selinux'
depends 'yum-centos', '>= 3.2.0'
depends 'yum-epel'

issues_url 'https://launchpad.net/openstack-chef'
source_url 'https://opendev.org/openstack/cookbook-openstack-common'
chef_version '>= 16.0'
