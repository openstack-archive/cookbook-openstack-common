# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# Attributes:: database
#
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013, SUSE Linux GmbH
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
# contain one of 'sqlite', 'mysql', 'db2' or 'postgresql'
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

# Default database attributes
default['openstack']['db']['server_role'] = 'os-ops-database'
default['openstack']['db']['service_type'] = 'mysql'
# Database connection options. Should include starting '?'
default['openstack']['db']['options'] = {
   mysql: '?charset=utf8',
   postgresql: '',
   sqlite: '',
   db2: '?charset=utf8',
   nosql: ''
}

# Database used by the OpenStack Compute (Nova) service
default['openstack']['db']['compute']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['compute']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['compute']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['compute']['db_name'] = 'nova'
default['openstack']['db']['compute']['username'] = 'nova'
default['openstack']['db']['compute']['options'] = node['openstack']['db']['options']

# Database used by the OpenStack Identity (Keystone) service
default['openstack']['db']['identity']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['identity']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['identity']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['identity']['db_name'] = 'keystone'
default['openstack']['db']['identity']['username'] = 'keystone'
default['openstack']['db']['identity']['migrate'] = true
default['openstack']['db']['identity']['options'] = node['openstack']['db']['options']

# Database used by the OpenStack Image (Glance) service
default['openstack']['db']['image']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['image']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['image']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['image']['db_name'] = 'glance'
default['openstack']['db']['image']['username'] = 'glance'
default['openstack']['db']['image']['migrate'] = true
default['openstack']['db']['image']['options'] = node['openstack']['db']['options']

# Database used by the OpenStack Network (Neutron) service
default['openstack']['db']['network']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['network']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['network']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['network']['db_name'] = 'neutron'
default['openstack']['db']['network']['username'] = 'neutron'
default['openstack']['db']['network']['options'] = node['openstack']['db']['options']
# The SQLAlchemy connection string used to connect to the slave database
default['openstack']['db']['network']['slave_connection'] = ''
# Database reconnection retry times - in event connectivity is lost
default['openstack']['db']['network']['max_retries'] = 10
# Database reconnection interval in seconds - if the initial connection to the
# database fails
default['openstack']['db']['network']['retry_interval'] = 10
# Minimum number of SQL connections to keep open in a pool
default['openstack']['db']['network']['min_pool_size'] = 1
# Maximum number of SQL connections to keep open in a pool
default['openstack']['db']['network']['max_pool_size'] = 10
# Timeout in seconds before idle sql connections are reaped
default['openstack']['db']['network']['idle_timeout'] = 3600
# If set, use this value for max_overflow with sqlalchemy
default['openstack']['db']['network']['max_overflow'] = 20
# Verbosity of SQL debugging information. 0=None, 100=Everything
default['openstack']['db']['network']['connection_debug'] = 0
# Add python stack traces to SQL as comment strings
default['openstack']['db']['network']['connection_trace'] = false
# If set, use this value for pool_timeout with sqlalchemy
default['openstack']['db']['network']['pool_timeout'] = 10

# Database used by the OpenStack Block Storage (Cinder) service
default['openstack']['db']['block-storage']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['block-storage']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['block-storage']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['block-storage']['db_name'] = 'cinder'
default['openstack']['db']['block-storage']['username'] = 'cinder'
default['openstack']['db']['block-storage']['options'] = node['openstack']['db']['options']

# Database used by the OpenStack Dashboard (Horizon)
default['openstack']['db']['dashboard']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['dashboard']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['dashboard']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['dashboard']['db_name'] = 'horizon'
default['openstack']['db']['dashboard']['username'] = 'dash'
default['openstack']['db']['dashboard']['migrate'] = true
default['openstack']['db']['dashboard']['options'] = node['openstack']['db']['options']

# Database used by OpenStack Metering (Ceilometer)
default['openstack']['db']['telemetry']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['telemetry']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['telemetry']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['telemetry']['db_name'] = 'ceilometer'
default['openstack']['db']['telemetry']['username'] = 'ceilometer'
default['openstack']['db']['telemetry']['nosql']['used'] = false
default['openstack']['db']['telemetry']['nosql']['port'] = '27017'
default['openstack']['db']['telemetry']['options'] = node['openstack']['db']['options']

# Database used by OpenStack Orchestration (Heat)
default['openstack']['db']['orchestration']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['orchestration']['host'] = node['openstack']['endpoints']['db']['host']
default['openstack']['db']['orchestration']['port'] = node['openstack']['endpoints']['db']['port']
default['openstack']['db']['orchestration']['db_name'] = 'heat'
default['openstack']['db']['orchestration']['username'] = 'heat'
default['openstack']['db']['orchestration']['options'] = node['openstack']['db']['options']

# Switch to store the MySQL root password in a databag instead of
# using the generated OpenSSL cookbook secure_password one.
default['openstack']['db']['root_user_use_databag'] = false

# If above root_user_use_databag is true, the below string
# will be passed to the get_password library routine.
default['openstack']['db']['root_user_key'] = 'mysqlroot'
