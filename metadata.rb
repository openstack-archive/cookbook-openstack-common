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

depends 'apt', '~> 4.0'
depends 'database', '~> 4.0.2'
depends 'mariadb', '~> 0.3.1'
depends 'mysql', '~> 7.2.0'
depends 'yum', '~> 3.5.4'
depends 'yum-epel', '~> 0.6.0'
depends 'galera', '~> 0.4.1'
depends 'poise-python', '~> 1.4.0'
