# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# Attributes:: database
#
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013-2014, SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ======================== OpenStack DB Support ================================
#
# This section of node attributes stores information about the database hosts
# used in an OpenStack deployment.
#
# There is no 'scheme' key. Instead, there is a 'service_type' key that should
# contain one of 'sqlite', 'mysql', or 'postgresql'
#
# The ::Openstack::db(<SERVICE_NAME>) library routine allows a lookup from any recipe
# to this array, returning the host information for the server that contains
# the database for <SERVICE_NAME>, where <SERVICE_NAME> is one of 'compute' (Nova),
# 'image' (Glance), 'identity' (Keystone), 'network' (Neutron), or 'volume' (Cinder)
#
# The ::Openstack::db_connection(<SERVICE_NAME>, <USER>, <PASSWORD>) library routine
# returns the SQLAlchemy DB URI for <SERVICE_NAME>, with the supplied user and password
# that a calling service might be using when connecting to the database.
#
# For example, let's assume that the database that is used by the OpenStack Identity
# service (Keystone) is configured as follows:
#
#   host: 192.168.0.3
#   port: 3306
#   service_type: mysql
#   db_name: keystone
#
# Further suppose that a node running the OpenStack Identity API service needs to
# connect to the above identity database server. It has the following in it's node
# attributes:
#
#   node['openstack']['db']['identity']['username'] = 'keystone'
#
# In a 'keystone' recipe, you might find the following code:
#
#   user = node['openstack']['db']['identity']['username']
#   pass = get_password 'db', 'keystone'
#
#   sql_connection = ::Openstack::db_uri('identity', user, pass)
#
# The sql_connection variable would then be set to "mysql://keystone:password@192.168.0.3:keystone"
# and could then be written to the keystone.conf file in a template.
#
# Database Migrations:
#
#   node['openstack']['db'][<SERVICE_NAME>]['migrate']
#
# The above attribute causes database migrations to be executed for the given
# service.  There are cases where migrations should not be executed.  For
# example when upgrading a zone, and the image or identity database are replicated
# across many zones.
#

# ******************** Database Endpoint **************************************
default['openstack']['endpoints']['db']['host'] = '127.0.0.1'
default['openstack']['endpoints']['db']['scheme'] = nil
default['openstack']['endpoints']['db']['port'] = '3306'
default['openstack']['endpoints']['db']['path'] = nil
default['openstack']['endpoints']['db']['bind_interface'] = nil
default['openstack']['endpoints']['db']['enabled_slave'] = false
default['openstack']['endpoints']['db']['slave_host'] = '127.0.0.1'
default['openstack']['endpoints']['db']['slave_port'] = '3316'

# Default database attributes
default['openstack']['db']['server_role'] = 'os-ops-database'
# Database charset during create database
default['openstack']['db']['charset'] = {
  mysql: 'utf8',
  'percona-cluster' => 'utf8',
  mariadb: 'utf8',
  postgresql: nil,
  pgsql: nil,
  sqlite: nil,
  nosql: nil,
  galera: 'utf8'
}

# Database connection options. Should include starting '?'
default['openstack']['db']['options'] = {
  mysql: "?charset=#{node['openstack']['db']['charset']['mysql']}",
  'percona-cluster' => "?charset=#{node['openstack']['db']['charset']['percona-cluster']}",
  mariadb: "?charset=#{node['openstack']['db']['charset']['mariadb']}",
  postgresql: '',
  sqlite: '',
  nosql: '',
  galera: "?charset=#{node['openstack']['db']['charset']['galera']}"
}

# platform and DBMS-specific python client packages
default['openstack']['db']['python_packages'] = {
  postgresql: ['python-psycopg2'],
  sqlite: []
}
case node['platform_family']
when 'rhel'
  default['openstack']['db']['service_type'] = 'mariadb'
  default['openstack']['db']['python_packages']['mysql'] = ['MySQL-python']
  default['openstack']['db']['python_packages']['mariadb'] = ['MySQL-python']
  default['openstack']['db']['python_packages']['percona-cluster'] = ['MySQL-python']
  default['openstack']['db']['python_packages']['galera'] = ['MySQL-python']
when 'suse'
  default['openstack']['db']['service_type'] = 'mysql'
  default['openstack']['db']['python_packages']['mysql'] = ['python-mysql']
  default['openstack']['db']['python_packages']['mariadb'] = ['python-mysql']
  default['openstack']['db']['python_packages']['galera'] = ['python-mysql']
  default['openstack']['db']['python_packages']['percona-cluster'] = ['python-mysql']
when 'debian'
  default['openstack']['db']['service_type'] = 'mysql'
  default['openstack']['db']['python_packages']['mysql'] = ['python-mysqldb']
  default['openstack']['db']['python_packages']['mariadb'] = ['python-mysqldb']
  default['openstack']['db']['python_packages']['percona-cluster'] = ['python-mysqldb']
  default['openstack']['db']['python_packages']['galera'] = ['python-mysqldb']
end

# Database used by the OpenStack services
node['openstack']['common']['services'].each do |service, project|
  default['openstack']['db'][service]['service_type'] = node['openstack']['db']['service_type']
  default['openstack']['db'][service]['host'] = node['openstack']['endpoints']['db']['host']
  default['openstack']['db'][service]['port'] = node['openstack']['endpoints']['db']['port']
  default['openstack']['db'][service]['db_name'] = project
  default['openstack']['db'][service]['username'] = project
  default['openstack']['db'][service]['options'] = node['openstack']['db']['options']

  default['openstack']['db'][service]['slave_host'] = node['openstack']['endpoints']['db']['slave_host']
  default['openstack']['db'][service]['slave_port'] = node['openstack']['endpoints']['db']['slave_port']

  case service
  when 'dashboard'
    default['openstack']['db'][service]['migrate'] = true
  when 'identity'
    default['openstack']['db'][service]['migrate'] = true
  when 'image'
    default['openstack']['db'][service]['migrate'] = true
  when 'network'
    # The SQLAlchemy connection string used to connect to the slave database
    default['openstack']['db'][service]['slave_connection'] = ''

    # Database reconnection retry times - in event connectivity is lost
    default['openstack']['db'][service]['max_retries'] = 10

    # Database reconnection interval in seconds - if the initial connection to the database fails
    default['openstack']['db'][service]['retry_interval'] = 10

    # Minimum number of SQL connections to keep open in a pool
    default['openstack']['db'][service]['min_pool_size'] = 1

    # Maximum number of SQL connections to keep open in a pool
    default['openstack']['db'][service]['max_pool_size'] = 10

    # Timeout in seconds before idle sql connections are reaped
    default['openstack']['db'][service]['idle_timeout'] = 3600

    # If set, use this value for max_overflow with sqlalchemy
    default['openstack']['db'][service]['max_overflow'] = 20

    # Verbosity of SQL debugging information. 0=None, 100=Everything
    default['openstack']['db'][service]['connection_debug'] = 0

    # Add python stack traces to SQL as comment strings
    default['openstack']['db'][service]['connection_trace'] = false

    # If set, use this value for pool_timeout with sqlalchemy
    default['openstack']['db'][service]['pool_timeout'] = 10
  when 'telemetry'
    default['openstack']['db'][service]['nosql']['used'] = false
    default['openstack']['db'][service]['nosql']['port'] = '27017'
  end
end

# DB key to the get_password library routine
default['openstack']['db']['root_user_key'] = 'mysqlroot'
