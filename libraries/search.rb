#
# Cookbook Name:: openstack-common
# library:: search
#
# Copyright 2013, AT&T Services, Inc.
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

module ::Openstack
  # Search the nodes environment for the given role.
  #
  # @param [String] role The role to be found.
  # @return [Array] The matching result or an empty list.
  def search_for role, &block
    query = "chef_environment:#{node.chef_environment} AND roles:#{role}"

    search(:node, query, &block).first
  end

  # Search for memcache servers.  Will return the value for
  # ["openstack"]["memcache_servers"] when set, otherwise
  # will perform the search.
  #
  # @param [String] role The role to be found (optional).
  # @return [Array] A list of memcached servers in format
  # '<ip>:<port>'.
  def memcached_servers role="infra-caching"
    unless node['openstack']['memcache_servers']
      search_for(role).map do |n|
        listen = n['memcached']['listen']
        port = n['memcached']['port'] || "11211"

        "#{listen}:#{port}"
      end.sort
    else
      node['openstack']['memcache_servers'].length != 0 ?
        node['openstack']['memcache_servers'] : []
    end
  end

  # Search for rabbit servers.
  #
  # @param [String] role The role to be found (optional).
  # @return [Array] A list of rabbit servers in format
  # '<ip>:<port>'.
  def rabbit_servers role="infra-messaging"
    search_for(role).map do |n|
      address = n['rabbitmq']['address']
      port = n['rabbitmq']['port'] || "5672"

      "#{address}:#{port}"
    end.sort
  end
end
