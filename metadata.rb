name             'openstack-common'
maintainer       'openstack-chef'
maintainer_email 'openstack-discuss@lists.openstack.org'
license          'Apache-2.0'
description      'Common OpenStack attributes, libraries and recipes.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
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
depends 'poise-python', '~> 1.7'
depends 'selinux'

issues_url 'https://launchpad.net/openstack-chef' if respond_to?(:issues_url)
source_url 'https://github.com/openstack/cookbook-openstack-common' if respond_to?(:source_url)
chef_version '>= 12.5' if respond_to?(:chef_version)
