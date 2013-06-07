#
# Cookbook Name:: openstack-common
# library:: memcache
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
  # Returns list of memcached servers in environment in format '<ip>:<port>'.
  # If the attribute ["openstack"]["memcache_servers"] is set we will use it
  # otherwise we will search based upon role.
  # env - sets environment where to search
  # role - sets role that is used to filter out memcached nodes
  def memcached_servers(env=node.chef_environment, role="infra-caching")
    unless node['openstack']['memcache_servers']
      search(:node, "chef_environment:#{env} AND roles:#{role}").map do |n|
        "#{n['memcached']['listen']}:11211"
      end.sort
    else
      node['openstack']['memcache_servers'].length != 0 ?
        node['openstack']['memcache_servers'] : []
    end
  end
end
