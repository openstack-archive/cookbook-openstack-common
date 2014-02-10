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

case node['platform_family']
when 'debian'
  package 'ubuntu-cloud-keyring' do
    action :install
  end

  apt_components = node['openstack']['apt']['components']

  # Simple variable substitution for LSB codename and OpenStack release
  apt_components.each do | comp |
    comp.gsub! '%release%', node['openstack']['release']
    comp.gsub! '%codename%', node['lsb']['codename']
  end

  apt_repository 'openstack-ppa' do
    uri node['openstack']['apt']['uri']
    components apt_components
  end

when 'rhel'

  if node['openstack']['yum']['rdo_enabled']
    repo_action = :add
  else
    repo_action = :remove
  end

  yum_repository "RDO-#{node['openstack']['release']}" do
    description "OpenStack RDO repo for #{node['openstack']['release']}"
    gpgkey node['openstack']['yum']['repo-key']
    baseurl node['openstack']['yum']['uri']
    enabled true
    action repo_action
  end

when 'suse'
  if node['lsb']['description'].nil?
    # Ohai lsb does not work at all on SLES11SP3
    # See https://tickets.opscode.com/browse/OHAI-454
    # Until then, copy chef's lsb_release parsing code from its lsb module.
    package 'lsb-release'

    Mixlib::ShellOut.new('lsb_release -a').run_command.stdout.split("\n").each do |line|
      case line
      when /^Description:\s+(.+)$/
        node.set_unless['lsb']['description'] = Regexp.last_match[1]
      when /^Release:\s+(.+)$/
        node.set_unless['lsb']['release'] = Regexp.last_match[1]
      end
    end
  end
  if node['lsb']['description'][/^SUSE Linux Enterprise Server/]
    release, patchlevel = node['platform_version'].split('.')
    zypp_release = "SLE_#{release}_SP#{patchlevel}"
  elsif node['lsb']['description'][/^openSUSE/]
    zypp_release = 'openSUSE_' + node['lsb']['release']
  end
  zypp = node['openstack']['zypp']
  repo_uri = zypp['uri'].gsub(
    '%release%', node['openstack']['release'].capitalize)
  repo_uri.gsub! '%suse-release%', zypp_release
  repo_alias = 'Cloud:OpenStack:' + node['openstack']['release'].capitalize

  # TODO(iartarisi) this should be moved to its own cookbook
  bash 'add repository key' do
    cwd '/tmp'
    code <<-EOH
      gpg --keyserver pgp.mit.edu --recv-keys #{zypp['repo-key']}
      gpg --armor --export #{zypp['repo-key']} > cloud.asc
      rpm --import cloud.asc
      rm -f cloud.asc
    EOH

    not_if { Mixlib::ShellOut.new('rpm -qa gpg-pubkey*').run_command.stdout.include? zypp['repo-key'].downcase }
  end

  execute 'add repository' do
    command "zypper addrepo --check #{repo_uri} #{repo_alias}"
    not_if { Mixlib::ShellOut.new('zypper repos --export -').run_command.stdout.include? repo_uri }
  end
end
