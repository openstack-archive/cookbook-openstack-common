# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# Attributes:: messaging
#
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013-2014, SUSE Linux GmbH
# Copyright 2013-2014, Rackspace US, Inc.
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

# ******************** RabbitMQ Endpoint **************************************
%w(endpoints bind_service).each do |type|
  default['openstack'][type]['mq']['host'] = '127.0.0.1'
  default['openstack'][type]['mq']['port'] = '5672'
end
default['openstack']['bind_service']['mq']['interface'] = nil

###################################################################
# Services to assign mq attributes for
###################################################################
services = %w(bare-metal block-storage compute database dns image
              identity telemetry network orchestration)

###################################################################
# Generic default attributes
###################################################################
default['openstack']['mq']['server_role'] = 'os-ops-messaging'
default['openstack']['mq']['service_type'] = 'rabbit'
default['openstack']['mq']['user'] = 'openstack'
default['openstack']['mq']['vhost'] = '/'

# defined in oslo/messaging/_drivers/amqp.py
default['openstack']['mq']['durable_queues'] = false
default['openstack']['mq']['auto_delete'] = false

###################################################################
# Default rabbit values (for attribute assignment below)
###################################################################
# global switch for handling rabbit ssl
default['openstack']['mq']['rabbitmq']['use_ssl'] = false
# SSL version to use (valid only if SSL enabled)
default['openstack']['mq']['rabbitmq']['kombu_ssl_version'] = nil
# SSL key file (valid only if SSL enabled)
default['openstack']['mq']['rabbitmq']['kombu_ssl_keyfile'] = nil
# SSL cert file (valid only if SSL enabled)
default['openstack']['mq']['rabbitmq']['kombu_ssl_certfile'] = nil
# SSL certification authority file (valid only if SSL enabled)
default['openstack']['mq']['rabbitmq']['kombu_ssl_ca_certs'] = nil
# How long to wait before reconnecting in response to an AMQP consumer cancel notification
default['openstack']['mq']['rabbitmq']['kombu_reconnect_delay'] = 1.0
# How long to wait before considering a reconnect attempt to have failed.
# This value should not be longer than rpc_response_timeout
default['openstack']['mq']['rabbitmq']['kombu_reconnect_timeout'] = 60
# global switch for handling rabbit ha
default['openstack']['mq']['rabbitmq']['ha'] = false
# global switch for number of seconds after which the Rabbit broker is considered down if heartbeat's keep-alive fails (0 disable the heartbeat)
default['openstack']['mq']['rabbitmq']['heartbeat_timeout_threshold'] = 0
# global switch for how often times during the heartbeat_timeout_threshold we check the heartbeat
default['openstack']['mq']['rabbitmq']['heartbeat_rate'] = 2

rabbit_defaults = {
  rabbit_max_retries: 0,
  rabbit_retry_interval: 1,
  userid: node['openstack']['mq']['user'],
  vhost: node['openstack']['mq']['vhost'],
  port: node['openstack']['endpoints']['mq']['port'],
  host: node['openstack']['endpoints']['mq']['host'],
  ha: node['openstack']['mq']['rabbitmq']['ha'],
  heartbeat_timeout_threshold: node['openstack']['mq']['rabbitmq']['heartbeat_timeout_threshold'],
  heartbeat_rate: node['openstack']['mq']['rabbitmq']['heartbeat_rate'],
  use_ssl: node['openstack']['mq']['rabbitmq']['use_ssl'],
  kombu_ssl_version: node['openstack']['mq']['rabbitmq']['kombu_ssl_version'],
  kombu_ssl_keyfile: node['openstack']['mq']['rabbitmq']['kombu_ssl_keyfile'],
  kombu_ssl_certfile: node['openstack']['mq']['rabbitmq']['kombu_ssl_certfile'],
  kombu_ssl_ca_certs: node['openstack']['mq']['rabbitmq']['kombu_ssl_ca_certs'],
  kombu_reconnect_delay: node['openstack']['mq']['rabbitmq']['kombu_reconnect_delay'],
  kombu_reconnect_timeout: node['openstack']['mq']['rabbitmq']['kombu_reconnect_timeout'],
}

###################################################################
# Assign default mq attributes for every service
###################################################################
services.each do |svc|
  default['openstack']['mq'][svc]['service_type'] = node['openstack']['mq']['service_type']

  default['openstack']['mq'][svc]['durable_queues'] =
    node['openstack']['mq']['durable_queues']
  default['openstack']['mq'][svc]['auto_delete'] =
    node['openstack']['mq']['auto_delete']

  rabbit_defaults.each do |key, val|
    default['openstack']['mq'][svc]['rabbit'][key.to_s] = val
  end
end
