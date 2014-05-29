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

module ::Openstack # rubocop:disable Documentation
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
    node['openstack']['endpoints'].each do | name, info |
      block.call(name, info)
    end
  rescue
    nil
  end

  # Instead of specifying the verbose node['openstack']['db'][service],
  # this shortcut allows the simpler and shorter db(service), where
  # service is one of 'compute', 'image', 'identity', 'network', 'dashboard'
  # 'orchestration', 'telemetry' 'block-storage' and 'volume'
  def db(service)
    node['openstack']['db'][service]
  rescue
    nil
  end

  # Shortcut to get the SQLAlchemy DB URI for a named service
  def db_uri(service, user, pass) # rubocop:disable MethodLength, CyclomaticComplexity
    info = db(service)
    if info
      host = info['host']
      port = info['port'].to_s
      type = info['service_type']
      name = info['db_name']
      options = info['options'][type]

      # Normalize to the SQLAlchemy standard db type identifier
      case type
      when 'db2'
        # NoSQL is used for telemetry in the DB2 case
        if service == 'telemetry' && node['openstack']['db']['telemetry']['nosql']['used']
          options = info['options']['nosql']
          port = info['nosql']['port']
          type = 'db2'
        else
          type = 'ibm_db_sa'
        end
      when 'pgsql'
        type = 'postgresql'
      end

      # Build uri
      case type
      when 'mysql', 'postgresql', 'db2', 'ibm_db_sa'
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
  end

  # Return the IPv4 address for the hash.
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

  private

  # Instead of specifying the verbose node['openstack']['endpoints'][name],
  # this shortcut allows the simpler and shorter endpoint(name)
  def endpoint_for(name)
    node['openstack']['endpoints'][name]
  rescue
    nil
  end
end
