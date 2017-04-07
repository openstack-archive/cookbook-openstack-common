# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# library:: default
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

platform_options = node['openstack']['common']['platform']
case node['platform_family']
when 'debian'
  if node['openstack']['apt']['update_apt_cache']
    # Ensure we've done an apt-update first or packages won't be found.
    include_recipe 'apt'
  end
  package 'ubuntu-cloud-keyring' do
    options platform_options['package_overrides']
    action :upgrade
  end

  if node['openstack']['apt']['live_updates_enabled']
    apt_components = node['openstack']['apt']['components']
    apt_repository 'openstack-ppa' do
      uri node['openstack']['apt']['uri']
      distribution "#{node['lsb']['codename']}-updates/#{node['openstack']['release']}"
      components apt_components
    end
  end
when 'rhel'
  include_recipe 'yum' if node['openstack']['yum']['update_yum_cache']

  if node['openstack']['yum']['rdo_enabled']
    repo_action = :add
    include_recipe 'yum-epel'
  elsif FileTest.exist? "/etc/yum.repos.d/RDO-#{node['openstack']['release']}.repo"
    repo_action = :remove
  else
    repo_action = :nothing
  end

  yum_repository "RDO-#{node['openstack']['release']}" do
    description "OpenStack RDO repo for #{node['openstack']['release']}"
    gpgkey node['openstack']['yum']['repo-key']
    baseurl node['openstack']['yum']['uri']
    gpgcheck node['openstack']['yum']['gpgcheck']
    enabled true
    action repo_action
  end
end

if node['openstack']['databag_type'] == 'vault'
  chef_gem 'chef-vault' do
    version node['openstack']['vault_gem_version']
  end
end
