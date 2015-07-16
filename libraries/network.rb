# encoding: UTF-8

#
# Cookbook Name:: openstack-common
# library:: network
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

# Network methods
module ::Openstack
  # return the IPv4 (default) address of the given interface.
  #
  # @param [String] interface The interface to query.
  # @param [String] family The protocol family to use.
  # @param [Mash] nodeish The node object to query.
  # @param [Boolean] drop_vips Option to exclude virtual ips with netmask 32 (ipv4) or 128 (ipv6).
  # @return [String] The address or log error when address is nil
  def address_for(interface, family = node['openstack']['endpoints']['family'], nodeish = node, drop_vips = true)
    Chef::Log.debug("address_for(#{interface}, #{family}, #{nodeish})")
    if interface == 'all'
      if family == 'inet6'
        return '::'
      else
        return '0.0.0.0'
      end
    end
    fail "Interface #{interface} does not exist" unless nodeish['network']['interfaces'][interface]
    addresses = nodeish['network']['interfaces'][interface]['addresses']
    fail "Interface #{interface} has no addresses assigned" if addresses.to_a.empty?
    get_address addresses, family, drop_vips
  end

  private

  def get_address(addresses, family,  drop_vips)
    case family
    when 'inet'
      vip_prefixlen = '32'
    when 'inet6'
      vip_prefixlen = '128'
    end
    addresses.each do |addr, data|
      return addr if data['family'] == family && (data['prefixlen'] != vip_prefixlen || !drop_vips)
    end
    fail "No address for family #{family} found"
  end
end
