# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# recipe:: openrc
#
# Copyright 2014 IBM Corp.
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

# Chef
class ::Chef::Recipe
  include ::Openstack
end

# check attributes before searching
if node['openstack']['identity'] && node['openstack']['identity']['admin_tenant_name'] && node['openstack']['identity']['admin_user']
  ksadmin_tenant_name = node['openstack']['identity']['admin_tenant_name']
  ksadmin_user = node['openstack']['identity']['admin_user']
else
  identity_service_role = node['openstack']['identity_service_chef_role']
  keystone = search_for(identity_service_role).first

  if keystone.nil?
    Chef::Log.warn("openrc not created, identity role node not found: #{identity_service_role}")
    return
  end

  ksadmin_tenant_name = keystone['openstack']['identity']['admin_tenant_name']
  ksadmin_user = keystone['openstack']['identity']['admin_user']
end

ksadmin_pass = get_password 'user', ksadmin_user
identity_endpoint = endpoint 'identity-api'
volume_api_version = 2
volume_api_path = node['openstack']['endpoints']['block-storage-api']['path']
volume_api_version = volume_api_path[/\d/].to_i unless volume_api_path.to_s.empty?

directory node['openstack']['openrc']['path'] do
  owner node['openstack']['openrc']['user']
  group node['openstack']['openrc']['group']
  mode node['openstack']['openrc']['path_mode']
  recursive true
end

template "#{node['openstack']['openrc']['path']}/#{node['openstack']['openrc']['file']}" do
  source 'openrc.erb'
  owner node['openstack']['openrc']['user']
  group node['openstack']['openrc']['group']
  mode node['openstack']['openrc']['file_mode']
  sensitive true
  variables(
    user: ksadmin_user,
    tenant: ksadmin_tenant_name,
    password: ksadmin_pass,
    identity_endpoint: identity_endpoint.to_s,
    volume_api_version: volume_api_version
  )
end
