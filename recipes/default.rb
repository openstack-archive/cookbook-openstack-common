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

case node["platform_family"]
when "debian"
  package "ubuntu-cloud-keyring" do
    action :install
  end

  apt_uri = node["openstack"]["apt"]["uri"]
  log("Setting APT repository to #{apt_uri}, with components:") { level :info }

  apt_components = node["openstack"]["apt"]["components"]

  # Simple variable substitution for LSB codename and OpenStack release
  apt_components.each do | comp |
    comp = comp.gsub "%release%", node["openstack"]["release"]
    comp = comp.gsub "%codename%", node["lsb"]["codename"]
    log("  #{comp}") { level :info }
  end

  apt_repository "openstack-ppa" do
    uri node["openstack"]["apt"]["uri"]
    components apt_components
  end

when "suse"
  zypp = node["openstack"]["zypp"]
  repo_uri = zypp["uri"].gsub(
    "%release%", node["openstack"]["release"].capitalize)
  repo_uri.gsub! "%suse-release%", zypp["release"]

  # TODO(iartarisi) this should be moved to its own cookbook
  bash "add repository key" do
    cwd "/tmp"
    code <<-EOH
      gpg --keyserver pgp.mit.edu --recv-keys #{zypp["repo-key"]}
      gpg --armor --export #{zypp["repo-key"]} > cloud.asc
      rpm --import cloud.asc
      rm -f cloud.asc
    EOH

    not_if { `rpm -qa gpg-pubkey*`.include? zypp["repo-key"].downcase }
  end

  execute "add repository" do
    command "zypper addrepo --check #{repo_uri} Cloud:OpenStack"
    not_if { `zypper repos --export -`.include? repo_uri }
  end
end
