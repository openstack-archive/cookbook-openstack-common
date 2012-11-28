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

if node["platform_family"] == "debian"

  package "ubuntu-cloud-keyring" do
    action :install
  end

  apt_uri = node["openstack"]["apt"]["uri"]
  ::Chef::Log.info("Setting APT repository to #{apt_uri}, with components:")

  apt_components = node["openstack"]["apt"]["components"]

  # Simple variable substitution for LSB codename and OpenStack release
  apt_components.each do | comp |
    comp = comp.gsub "%release%", node["openstack"]["release"]
    comp = comp.gsub "%codename%", node["lsb"]["codename"]
    ::Chef::Log.info("  #{comp}")
  end

  apt_repository "openstack-ppa" do
    uri node["openstack"]["apt"]["uri"]
    distribution node["lsb"]["codename"]
    components apt_components
  end

end
