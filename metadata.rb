name 'openstack-common'
maintainer 'openstack-chef'
maintainer_email 'openstack-dev@lists.openstack.org'
issues_url 'https://launchpad.net/openstack-chef' if respond_to?(:issues_url)
source_url 'https://github.com/openstack/cookbook-openstack-common' if respond_to?(:source_url)
license 'Apache 2.0'
description 'Common OpenStack attributes, libraries and recipes.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '14.0.0'

recipe 'openstack-common', 'Installs/Configures common recipes'
recipe 'openstack-common::logging', 'Installs/Configures common logging'
recipe 'openstack-common::sysctl', 'Configures sysctl settings'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'apt', '~> 5.0'
depends 'database', '~> 6.1'
depends 'mariadb', '~> 0.3.3'
depends 'mysql', '~> 8.2'
depends 'yum', '~> 3.13'
depends 'yum-epel', '~> 2.0'
depends 'galera', '~> 0.4.1'
depends 'poise-python', '~> 1.5'
