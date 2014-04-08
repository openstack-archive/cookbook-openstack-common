# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# Recipe:: ceph_client
#
# Copyright 2014, x-ion GmbH
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

return unless node['openstack']['ceph']['setup_client']

case node['platform_family']
when 'debian'
  apt_repository 'ceph' do
    uri node['openstack']['ceph']['platform']['uri']
    distribution node['lsb']['codename']
    components ['main']
    key node['openstack']['ceph']['key-url']
  end
when 'fedora', 'rhel', 'suse' # :pragma-foodcritic: ~FC024 - won't fix this
  # TODO
end

directory '/etc/ceph' do
  user 'root'
  group 'root'
end

template '/etc/ceph/ceph.conf' do
  source 'ceph.conf.erb'
  user 'root'
  group 'root'
  mode '644'
  variables(
    global: node['openstack']['ceph']['global']
  )
end
