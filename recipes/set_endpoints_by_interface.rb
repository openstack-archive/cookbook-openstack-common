# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# recipe:: set_endpoints_by_interface
#
# Copyright 2013, Opscode, Inc.
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

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

# iterate over the endpoints, look for bind_interface to set the host
node['openstack']['endpoints'].keys.each do |component|
  unless node['openstack']['endpoints'][component]['bind_interface'].nil?
    ip_address = address_for node['openstack']['endpoints'][component]['bind_interface']
    node.default['openstack']['endpoints'][component]['host'] = ip_address
  end
end
