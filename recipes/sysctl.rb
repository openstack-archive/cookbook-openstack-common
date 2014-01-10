# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# recipe:: sysctl
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

directory '/etc/sysctl.d' do
  owner 'root'
  group 'root'
  mode 00755
end

template '/etc/sysctl.d/60-openstack.conf' do
  source '60-openstack.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
end

execute 'sysctl -p /etc/sysctl.d/60-openstack.conf' do
  action :nothing
  subscribes :run, 'template[/etc/sysctl.d/60-openstack.conf]', :immediately
end
