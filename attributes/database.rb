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

# Default database attributes
default['openstack']['db']['server_role'] = 'os-ops-database'
default['openstack']['db']['service_type'] = 'mysql'
default['openstack']['db']['host'] = '127.0.0.1'
default['openstack']['db']['port'] = '3306'

# Database used by the OpenStack Compute (Nova) service
default['openstack']['db']['compute']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['compute']['host'] = node['openstack']['db']['host']
default['openstack']['db']['compute']['port'] = node['openstack']['db']['port']
default['openstack']['db']['compute']['db_name'] = 'nova'
default['openstack']['db']['compute']['username'] = 'nova'

# Database used by the OpenStack Identity (Keystone) service
default['openstack']['db']['identity']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['identity']['host'] = node['openstack']['db']['host']
default['openstack']['db']['identity']['port'] = node['openstack']['db']['port']
default['openstack']['db']['identity']['db_name'] = 'keystone'
default['openstack']['db']['identity']['username'] = 'keystone'
default['openstack']['db']['identity']['migrate'] = true

# Database used by the OpenStack Image (Glance) service
default['openstack']['db']['image']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['image']['host'] = node['openstack']['db']['host']
default['openstack']['db']['image']['port'] = node['openstack']['db']['port']
default['openstack']['db']['image']['db_name'] = 'glance'
default['openstack']['db']['image']['username'] = 'glance'
default['openstack']['db']['image']['migrate'] = true

# Database used by the OpenStack Network (Neutron) service
default['openstack']['db']['network']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['network']['host'] = node['openstack']['db']['host']
default['openstack']['db']['network']['port'] = node['openstack']['db']['port']
default['openstack']['db']['network']['db_name'] = 'neutron'
default['openstack']['db']['network']['username'] = 'neutron'
# Enable the use of eventlet's db_pool for MySQL. The flags sql_min_pool_size,
# sql_max_pool_size and sql_idle_timeout are relevant only if this is enabled.
default['openstack']['db']['network']['sql_dbpool_enable'] = 'False'
# Database reconnection retry times - in event connectivity is lost
default['openstack']['db']['network']['sql_max_retries'] = 10
# Database reconnection interval in seconds - if the initial connection to the
# database fails
default['openstack']['db']['network']['reconnect_interval'] = 2
# Minimum number of SQL connections to keep open in a pool
default['openstack']['db']['network']['sql_min_pool_size'] = 1
# Maximum number of SQL connections to keep open in a pool
default['openstack']['db']['network']['sql_max_pool_size'] = 5
# Timeout in seconds before idle sql connections are reaped
default['openstack']['db']['network']['sql_idle_timeout'] = 3600

# Database used by the OpenStack Block Storage (Cinder) service
default['openstack']['db']['block-storage']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['block-storage']['host'] = node['openstack']['db']['host']
default['openstack']['db']['block-storage']['port'] = node['openstack']['db']['port']
default['openstack']['db']['block-storage']['db_name'] = 'cinder'
default['openstack']['db']['block-storage']['username'] = 'cinder'

# Database used by the OpenStack Dashboard (Horizon)
default['openstack']['db']['dashboard']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['dashboard']['host'] = node['openstack']['db']['host']
default['openstack']['db']['dashboard']['port'] = node['openstack']['db']['port']
default['openstack']['db']['dashboard']['db_name'] = 'horizon'
default['openstack']['db']['dashboard']['username'] = 'dash'

# Database used by OpenStack Metering (Ceilometer)
default['openstack']['db']['metering']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['metering']['host'] = node['openstack']['db']['host']
default['openstack']['db']['metering']['port'] = node['openstack']['db']['port']
default['openstack']['db']['metering']['db_name'] = 'ceilometer'
default['openstack']['db']['metering']['username'] = 'ceilometer'

# Database used by OpenStack Orchestration (Heat)
default['openstack']['db']['orchestration']['service_type'] = node['openstack']['db']['service_type']
default['openstack']['db']['orchestration']['host'] = node['openstack']['db']['host']
default['openstack']['db']['orchestration']['port'] = node['openstack']['db']['port']
default['openstack']['db']['orchestration']['db_name'] = 'heat'
default['openstack']['db']['orchestration']['username'] = 'heat'

# Switch to store the MySQL root password in a databag instead of
# using the generated OpenSSL cookbook secure_password one.
default['openstack']['db']['root_user_use_databag'] = false

# If above root_user_use_databag is true, the below string
# will be passed to the get_password library routine.
default['openstack']['db']['root_user_key'] = 'mysqlroot'
