#
# Cookbook Name:: openstack-common
# library:: default
#
# Copyright 2012, Jay Pipes
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

module Openstack
  # Instead of specifying the verbose node["openstack"]["endpoints"][name],
  # this shortcut allows the simpler and shorter endpoint(name)
  def endpoint(name)
    @node['openstack']['endpoints'][name]
  rescue
    nil
  end

  # Shortcut to get the full URI for an endpoint. If the "uri" key isn't
  # set in the endpoint hash, we use the Openstack::get_uri_from_mash
  # library routine from the openstack-utils cookbook to grab a URI object
  # and construct the URI object from the endpoint parts.
  def endpoint_uri(name)
    ep = endpoint(name)
    if ep && ep.has_key?("uri")
      ep["uri"]
    elsif ep
      ::Openstack::uri_from_hash(ep).to_s
    end
  end

  # Useful for iterating over the OpenStack endpoints
  def endpoints(&block)
    @node['openstack']['endpoints'].each do | name, info |
      block.call(name, info)
    end
  rescue
    nil
  end

  # Instead of specifying the verbose node["openstack"]["db"][service],
  # this shortcut allows the simpler and shorter db(service), where
  # service is one of 'compute', 'image', 'identity', 'network',
  # and 'volume'
  def db(service)
    @node['openstack']['db'][service]
  rescue
    nil
  end

  # Shortcut to get the SQLAlchemy DB URI for a named service
  def db_uri(service, user, pass)
    info = db(service)
    if info
      host = info['host']
      port = info['port'].to_s
      type = info['db_type']
      name = info['db_name']
      if type == 'postgresql'
        # Normalize to the SQLAlchemy standard db type identifier
        type = 'pgsql'
      end
      if type == 'mysql' or type == 'pgsql'
        result = "#{type}://#{user}:#{pass}@#{host}:#{port}/#{name}"
      elsif type == 'sqlite'
        # SQLite uses filepaths not db name
        path = info['path']
        result = "sqlite://#{path}"
    end
  end
end
