# encoding: UTF-8

#
# Cookbook Name:: openstack-common
# library:: endpoints
#
# Copyright 2012-2013, AT&T Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Endpoint methods
module ::Openstack
  # Instead of specifying the verbose node['openstack']['db'][service],
  # this shortcut allows the simpler and shorter db(service), where
  # service can be: 'compute', 'image', 'identity', 'network', etc.
  def db(service)
    node['openstack']['db'][service]
  rescue
    nil
  end

  # Shortcut to get the transport_url for rabbitmq
  def rabbit_transport_url(service)
    mq_user = node['openstack']['mq'][service]['rabbit']['userid']
    mq_password = get_password 'user', mq_user
    mq_port = node['openstack']['endpoints']['mq']['port']
    vhost = node['openstack']['mq']['vhost']
    bind_mq_address = bind_address node['openstack']['bind_service']['mq']
    url = 'rabbit://'
    if node['openstack']['mq']['cluster']
      node['openstack']['mq']['servers'].each do |server|
        url += "#{mq_user}:#{mq_password}@#{server}:#{mq_port}"
        url += ',' unless node['openstack']['mq']['servers'].last == server
      end
    else
      url += "#{mq_user}:#{mq_password}@#{bind_mq_address}:#{mq_port}"
    end
    url += vhost
    url
  end

  # Shortcut to get the SQLAlchemy DB URI for a named service
  def db_uri(service, user, pass, is_slave = false)
    info = db(service)
    return unless info

    if is_slave
      host = info['slave_host']
      port = info['slave_port'].to_s
    else
      host = info['host']
      port = info['port'].to_s
    end
    type = info['service_type']
    name = info['db_name']
    options = info['options'][type]

    # Normalize to the SQLAlchemy standard db type identifier
    case type
    when 'mariadb', 'galera', 'percona-cluster'
      type = 'mysql'
    end

    # Build uri
    case type
    when 'mysql'
      "mysql+pymysql://#{user}:#{pass}@#{host}:#{port}/#{name}#{options}"
    when 'sqlite'
      # SQLite uses filepaths not db name
      # README(galstrom): 3 slashes is a relative path, 4 slashes is an absolute path
      #  example: info['path'] = 'path/to/foo.db' -- will return sqlite:///foo.db
      #  example: info['path'] = '/path/to/foo.db' -- will return sqlite:////foo.db
      path = info['path']
      "#{type}:///#{path}#{options}"
    end
  end

  # Find the specific endpoint type ('internal', 'admin' or
  # 'public') for the given service.
  %w(public internal admin).each do |ep_type|
    define_method("#{ep_type}_endpoint") do |service|
      uri_from_hash(node['openstack']['endpoints'][ep_type][service])
    end
  end
end
