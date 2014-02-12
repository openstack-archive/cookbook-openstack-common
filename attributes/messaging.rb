# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# Attributes:: messaging
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
# The rabbitmq user's password is stored in an encrypted databag and accessed
# with openstack-common cookbook library's user_password routine.  You are
# expected to create the user, pass, vhost in a wrapper rabbitmq cookbook.
#

# Default messaging attributes
default['openstack']['mq']['server_role'] = 'os-ops-messaging'
default['openstack']['mq']['service_type'] = 'rabbitmq'
default['openstack']['mq']['host'] = '127.0.0.1'
default['openstack']['mq']['port'] = '5672'
default['openstack']['mq']['user'] = 'guest'
default['openstack']['mq']['vhost'] = '/'

# Messaging attributes used by the OpenStack Volume (Cinder) service
default['openstack']['mq']['block-storage']['service_type'] = node['openstack']['mq']['service_type']
default['openstack']['mq']['block-storage']['notification_topic'] = 'notifications'
case node['openstack']['mq']['block-storage']['service_type']
when 'qpid'
  default['openstack']['mq']['block-storage']['qpid']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['block-storage']['qpid']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['block-storage']['qpid']['qpid_hosts'] = ['127.0.0.1:5672']
  default['openstack']['mq']['block-storage']['qpid']['username'] = ''
  default['openstack']['mq']['block-storage']['qpid']['password'] = ''
  default['openstack']['mq']['block-storage']['qpid']['sasl_mechanisms'] = ''
  default['openstack']['mq']['block-storage']['qpid']['reconnect'] = true
  default['openstack']['mq']['block-storage']['qpid']['reconnect_timeout'] = 0
  default['openstack']['mq']['block-storage']['qpid']['reconnect_limit'] = 0
  default['openstack']['mq']['block-storage']['qpid']['reconnect_interval_min'] = 0
  default['openstack']['mq']['block-storage']['qpid']['reconnect_interval_max'] = 0
  default['openstack']['mq']['block-storage']['qpid']['reconnect_interval'] = 0
  default['openstack']['mq']['block-storage']['qpid']['heartbeat'] = 60
  default['openstack']['mq']['block-storage']['qpid']['protocol'] = 'tcp'
  default['openstack']['mq']['block-storage']['qpid']['tcp_nodelay'] = true
  default['openstack']['mq']['block-storage']['qpid']['notification_topic'] = node['openstack']['mq']['block-storage']['notification_topic']
when 'rabbitmq'
  default['openstack']['mq']['block-storage']['rabbit']['userid'] = node['openstack']['mq']['user']
  default['openstack']['mq']['block-storage']['rabbit']['vhost'] = node['openstack']['mq']['vhost']
  default['openstack']['mq']['block-storage']['rabbit']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['block-storage']['rabbit']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['block-storage']['rabbit']['ha'] = false
  default['openstack']['mq']['block-storage']['rabbit']['use_ssl'] = false
  default['openstack']['mq']['block-storage']['rabbit']['notification_topic'] = node['openstack']['mq']['block-storage']['notification_topic']
end

# Messaging attributes used by the OpenStack Compute (Nova) service
default['openstack']['mq']['compute']['service_type'] = node['openstack']['mq']['service_type']
case node['openstack']['mq']['compute']['service_type']
when 'qpid'
  default['openstack']['mq']['compute']['qpid']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['compute']['qpid']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['compute']['qpid']['qpid_hosts'] = ['127.0.0.1:5672']
  default['openstack']['mq']['compute']['qpid']['username'] = ''
  default['openstack']['mq']['compute']['qpid']['password'] = ''
  default['openstack']['mq']['compute']['qpid']['sasl_mechanisms'] = ''
  default['openstack']['mq']['compute']['qpid']['reconnect_timeout'] = 0
  default['openstack']['mq']['compute']['qpid']['reconnect_limit'] = 0
  default['openstack']['mq']['compute']['qpid']['reconnect_interval_min'] = 0
  default['openstack']['mq']['compute']['qpid']['reconnect_interval_max'] = 0
  default['openstack']['mq']['compute']['qpid']['reconnect_interval'] = 0
  default['openstack']['mq']['compute']['qpid']['heartbeat'] = 60
  default['openstack']['mq']['compute']['qpid']['protocol'] = 'tcp'
  default['openstack']['mq']['compute']['qpid']['tcp_nodelay'] = true
when 'rabbitmq'
  default['openstack']['mq']['compute']['rabbit']['userid'] = node['openstack']['mq']['user']
  default['openstack']['mq']['compute']['rabbit']['vhost'] = node['openstack']['mq']['vhost']
  default['openstack']['mq']['compute']['rabbit']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['compute']['rabbit']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['compute']['rabbit']['ha'] = false
  default['openstack']['mq']['compute']['rabbit']['use_ssl'] = false
end

# Messaging attributes used by the OpenStack Image (Glance) service
default['openstack']['mq']['image']['service_type'] = node['openstack']['mq']['service_type']
default['openstack']['mq']['image']['notifier_strategy'] = 'noop'
default['openstack']['mq']['image']['notification_topic'] = 'glance_notifications'
case node['openstack']['mq']['image']['service_type']
when 'qpid'
  default['openstack']['mq']['image']['qpid']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['image']['qpid']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['image']['qpid']['qpid_hosts'] = ['127.0.0.1:5672']
  default['openstack']['mq']['image']['qpid']['username'] = ''
  default['openstack']['mq']['image']['qpid']['password'] = ''
  default['openstack']['mq']['image']['qpid']['sasl_mechanisms'] = ''
  default['openstack']['mq']['image']['qpid']['reconnect'] = true
  default['openstack']['mq']['image']['qpid']['reconnect_timeout'] = 0
  default['openstack']['mq']['image']['qpid']['reconnect_limit'] = 0
  default['openstack']['mq']['image']['qpid']['reconnect_interval_min'] = 0
  default['openstack']['mq']['image']['qpid']['reconnect_interval_max'] = 0
  default['openstack']['mq']['image']['qpid']['reconnect_interval'] = 0
  default['openstack']['mq']['image']['qpid']['heartbeat'] = 60
  default['openstack']['mq']['image']['qpid']['protocol'] = 'tcp'
  default['openstack']['mq']['image']['qpid']['tcp_nodelay'] = true
  default['openstack']['mq']['image']['qpid']['notification_topic'] = node['openstack']['mq']['image']['notification_topic']
when 'rabbitmq'
  default['openstack']['mq']['image']['rabbit']['userid'] = node['openstack']['mq']['user']
  default['openstack']['mq']['image']['rabbit']['vhost'] = node['openstack']['mq']['vhost']
  default['openstack']['mq']['image']['rabbit']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['image']['rabbit']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['image']['rabbit']['use_ssl'] = false
  default['openstack']['mq']['image']['rabbit']['notification_topic'] = node['openstack']['mq']['image']['notification_topic']
end

# Messaging attributes used by the OpenStack Metering (Ceilometer) service
default['openstack']['mq']['metering']['service_type'] = node['openstack']['mq']['service_type']
case node['openstack']['mq']['metering']['service_type']
when 'qpid'
  default['openstack']['mq']['metering']['qpid']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['metering']['qpid']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['metering']['qpid']['qpid_hosts'] = ['127.0.0.1:5672']
  default['openstack']['mq']['metering']['qpid']['username'] = ''
  default['openstack']['mq']['metering']['qpid']['password'] = ''
  default['openstack']['mq']['metering']['qpid']['sasl_mechanisms'] = ''
  default['openstack']['mq']['metering']['qpid']['reconnect'] = true
  default['openstack']['mq']['metering']['qpid']['reconnect_timeout'] = 0
  default['openstack']['mq']['metering']['qpid']['reconnect_limit'] = 0
  default['openstack']['mq']['metering']['qpid']['reconnect_interval_min'] = 0
  default['openstack']['mq']['metering']['qpid']['reconnect_interval_max'] = 0
  default['openstack']['mq']['metering']['qpid']['reconnect_interval'] = 0
  default['openstack']['mq']['metering']['qpid']['heartbeat'] = 60
  default['openstack']['mq']['metering']['qpid']['protocol'] = 'tcp'
  default['openstack']['mq']['metering']['qpid']['tcp_nodelay'] = true
when 'rabbitmq'
  default['openstack']['mq']['metering']['rabbit']['userid'] = node['openstack']['mq']['user']
  default['openstack']['mq']['metering']['rabbit']['vhost'] = node['openstack']['mq']['vhost']
  default['openstack']['mq']['metering']['rabbit']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['metering']['rabbit']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['metering']['rabbit']['ha'] = false
  default['openstack']['mq']['metering']['rabbit']['use_ssl'] = false
end

# Messaging attributes used by the OpenStack Network (Neutron) service
default['openstack']['mq']['network']['service_type'] = node['openstack']['mq']['service_type']
case node['openstack']['mq']['network']['service_type']
when 'qpid'
  default['openstack']['mq']['network']['qpid']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['network']['qpid']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['network']['qpid']['qpid_hosts'] = ['127.0.0.1:5672']
  default['openstack']['mq']['network']['qpid']['username'] = ''
  default['openstack']['mq']['network']['qpid']['password'] = ''
  default['openstack']['mq']['network']['qpid']['sasl_mechanisms'] = ''
  default['openstack']['mq']['network']['qpid']['reconnect'] = true
  default['openstack']['mq']['network']['qpid']['reconnect_timeout'] = 0
  default['openstack']['mq']['network']['qpid']['reconnect_limit'] = 0
  default['openstack']['mq']['network']['qpid']['reconnect_interval_min'] = 0
  default['openstack']['mq']['network']['qpid']['reconnect_interval_max'] = 0
  default['openstack']['mq']['network']['qpid']['reconnect_interval'] = 0
  default['openstack']['mq']['network']['qpid']['heartbeat'] = 60
  default['openstack']['mq']['network']['qpid']['protocol'] = 'tcp'
  default['openstack']['mq']['network']['qpid']['tcp_nodelay'] = true
when 'rabbitmq'
  default['openstack']['mq']['network']['rabbit']['userid'] = node['openstack']['mq']['user']
  default['openstack']['mq']['network']['rabbit']['vhost'] = node['openstack']['mq']['vhost']
  default['openstack']['mq']['network']['rabbit']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['network']['rabbit']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['network']['rabbit']['ha'] = false
end

# Messaging attributes used by the OpenStack Orchestration (Heat) service
default['openstack']['mq']['orchestration']['service_type'] = node['openstack']['mq']['service_type']
case node['openstack']['mq']['orchestration']['service_type']
when 'qpid'
  default['openstack']['mq']['orchestration']['qpid']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['orchestration']['qpid']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['orchestration']['qpid']['qpid_hosts'] = ['127.0.0.1:5672']
  default['openstack']['mq']['orchestration']['qpid']['username'] = ''
  default['openstack']['mq']['orchestration']['qpid']['password'] = ''
  default['openstack']['mq']['orchestration']['qpid']['sasl_mechanisms'] = ''
  default['openstack']['mq']['orchestration']['qpid']['reconnect'] = true
  default['openstack']['mq']['orchestration']['qpid']['reconnect_timeout'] = 0
  default['openstack']['mq']['orchestration']['qpid']['reconnect_limit'] = 0
  default['openstack']['mq']['orchestration']['qpid']['reconnect_interval_min'] = 0
  default['openstack']['mq']['orchestration']['qpid']['reconnect_interval_max'] = 0
  default['openstack']['mq']['orchestration']['qpid']['reconnect_interval'] = 0
  default['openstack']['mq']['orchestration']['qpid']['heartbeat'] = 60
  default['openstack']['mq']['orchestration']['qpid']['protocol'] = 'tcp'
  default['openstack']['mq']['orchestration']['qpid']['tcp_nodelay'] = true
when 'rabbitmq'
  default['openstack']['mq']['orchestration']['rabbit']['userid'] = node['openstack']['mq']['user']
  default['openstack']['mq']['orchestration']['rabbit']['vhost'] = node['openstack']['mq']['vhost']
  default['openstack']['mq']['orchestration']['rabbit']['port'] = node['openstack']['mq']['port']
  default['openstack']['mq']['orchestration']['rabbit']['host'] = node['openstack']['mq']['host']
  default['openstack']['mq']['orchestration']['rabbit']['ha'] = false
  default['openstack']['mq']['orchestration']['rabbit']['use_ssl'] = false
end
