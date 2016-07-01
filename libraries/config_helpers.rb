# encoding: UTF-8

#
# Cookbook Name:: openstack-common
# library:: config_helpers
#
# Copyright 2016, cloudbau GmbH
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

# config helper methods
module ::Openstack
  # return a Mash with config options which can be used for the service config
  # templates
  # @param [String] service
  def merge_config_options(service)
    conf = deep_dup(node['openstack'][service]['conf'])
    conf_secrets = if node['openstack'][service]['conf_secrets']
                     deep_dup(node['openstack'][service]['conf_secrets'])
                   else
                     {}
                   end
    Chef::Mixin::DeepMerge.merge(conf, conf_secrets)
  end

  # return a full dup of the given Mash even if nested
  # @param kind_of(Mash) can be a Chef::Node::ImmutableMash and will output a
  # simple Mash on all layers
  def deep_dup(mash)
    duplicate = mash.dup
    duplicate.each_pair do |k, v|
      tv = duplicate[k]
      duplicate[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? deep_dup(tv) : v
    end
    duplicate
  end
end
