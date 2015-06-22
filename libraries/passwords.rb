# encoding: UTF-8

#
# Cookbook Name:: openstack-common
# library:: passwords
#
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2014, SUSE Linux, GmbH.
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

# Password methods
module ::Openstack
  # Library routine that returns an encrypted data bag value
  # for a supplied string. The key used in decrypting the
  # encrypted value should be located at
  # node['openstack']['secret']['key_path'].
  #
  def secret(bag_name, index)
    case node['openstack']['databag_type']
    when 'encrypted'
      encrypted_secret(bag_name, index)
    when 'standard'
      standard_secret(bag_name, index)
    when 'vault' # chef-vault, by convention use "vault_<bag_name>" as bag_name
      vault_secret('vault_' + bag_name, index)
    else
      ::Chef::Log.error("Unsupported value for node['openstack']['databag_type']")
    end
  end

  def encrypted_secret(bag_name, index)
    key_path = node['openstack']['secret']['key_path']
    ::Chef::Log.info "Loading encrypted databag #{bag_name}.#{index} using key at #{key_path}"
    secret = ::Chef::EncryptedDataBagItem.load_secret key_path
    ::Chef::EncryptedDataBagItem.load(bag_name, index, secret)[index]
  end

  def standard_secret(bag_name, index)
    ::Chef::Log.info "Loading databag #{bag_name}.#{index}"
    ::Chef::DataBagItem.load(bag_name, index)[index]
  end

  def vault_secret(bag_name, index)
    begin
      require 'chef-vault'
    rescue LoadError
      Chef::Log.warn("Missing gem 'chef-vault'")
    end
    ::Chef::Log.info "Loading vault secret #{index} from #{bag_name}"
    ::ChefVault::Item.load(bag_name, index)[index]
  end

  # Return a password using either data bags or attributes for
  # storage. The storage mechanism used is determined by the
  # node['openstack']['use_databags'] attribute.
  # @param [String] type of password, one of 'user', 'service', 'db' or 'token'
  # @param [String] the identifier of the password (usually the
  # component name, but can also be a token name
  # e.g. openstack_identity_bootstrap_token
  def get_password(type, key)
    unless %w(db user service token).include?(type)
      ::Chef::Log.error("Unsupported type for get_password: #{type}")
      return
    end

    if node['openstack']['use_databags']
      if type == 'token'
        secret node['openstack']['secret']['secrets_data_bag'], key
      else
        secret node['openstack']['secret']["#{type}_passwords_data_bag"], key
      end
    else
      node['openstack']['secret'][key][type]
    end
  end
end
