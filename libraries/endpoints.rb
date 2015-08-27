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

require 'uri'

# Endpoint methods
module ::Openstack
  # Shortcut to get the full URI for an endpoint, and return it as a URI object
  # First we get the attribute hash for the endpoint, using endpoint_for().
  # Then we call uri_from_hash(). If the hash has a 'uri' key,
  # this gets converted to a URI object and returned. If not, a URI object is
  # constructed from the endpoint parts in the endpoint hash, and returned
  def endpoint(name)
    ep = endpoint_for(name)
    uri_from_hash(ep) if ep
  end

  # Useful for iterating over the OpenStack endpoints
  def endpoints(&block)
    node['openstack']['endpoints'].each do |name, info|
      block.call(name, info)
    end
  rescue
    nil
  end

  # Instead of specifying the verbose node['openstack']['db'][service],
  # this shortcut allows the simpler and shorter db(service), where
  # service can be: 'compute', 'image', 'identity', 'network', etc.
  def db(service)
    node['openstack']['db'][service]
  rescue
    nil
  end

  # Shortcut to get the SQLAlchemy DB URI for a named service
  def db_uri(service, user, pass, is_slave = false) # rubocop:disable MethodLength, CyclomaticComplexity
    info = db(service)
    return unless info

    if is_slave
      host  = info['slave_host']
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
    when 'pgsql'
      type = 'postgresql'
    when 'mariadb', 'galera', 'percona-cluster'
      type = 'mysql'
    end

    # Build uri
    case type
    when 'mysql', 'postgresql'
      "#{type}://#{user}:#{pass}@#{host}:#{port}/#{name}#{options}"
    when 'sqlite'
      # SQLite uses filepaths not db name
      # README(galstrom): 3 slashes is a relative path, 4 slashes is an absolute path
      #  example: info['path'] = 'path/to/foo.db' -- will return sqlite:///foo.db
      #  example: info['path'] = '/path/to/foo.db' -- will return sqlite:////foo.db
      path = info['path']
      "#{type}:///#{path}#{options}"
    end
  end

  # Return the address for the hash.
  #
  # If the bind_interface is set, then return the first IP on the interface.
  # otherwise return the IP specified in the host attribute.
  def address(hash)
    bind_interface = hash['bind_interface'] if hash['bind_interface']

    if bind_interface
      return address_for bind_interface
    else
      return hash['host']
    end
  end

  # Get the admin endpoint for the specified service.
  # If there's no specific endpoint, then get the general service endpoint.
  def admin_endpoint(name)
    ep = specific_endpoint('admin', name)
    uri_from_hash(ep) if ep
  end

  # Get the public endpoint for the specified service.
  # If there's no specific endpoint, then get the general  service endpoint.
  def public_endpoint(name)
    ep = specific_endpoint('public', name)
    uri_from_hash(ep) if ep
  end

  # Get the internal endpoint for the specified service.
  # If there's no specific endpoint, then get the general  service endpoint.
  def internal_endpoint(name)
    ep = specific_endpoint('internal', name)
    uri_from_hash(ep) if ep
  end

  private

  # Instead of specifying the verbose node['openstack']['endpoints'][name],
  # this shortcut allows the simpler and shorter endpoint(name)
  def endpoint_for(name)
    node['openstack']['endpoints'][name]
  rescue
    nil
  end

  # Attempt to find the specific endpoint type ('internal', 'admin', or
  # 'public') for the given name.  If it's not found, then return the
  # general endpoint.
  def specific_endpoint(type, name)
    if node['openstack']['endpoints'][type].include? name
      node['openstack']['endpoints'][type][name]
    else
      # There may have been a subhash for the specified type, but it
      # didn't have the name we were looking for (and didn't throw
      # an exception either). In this case, attempt to use the general
      # endpoit
      endpoint_for(name)
    end
  rescue
    # Problem doing hash lookups for requested type of endpoint. Use
    # general endpoint instead
    endpoint_for(name)
  end
end
