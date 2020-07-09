#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Copyright:: 2011-2016, Chef Software, Inc.
# License:: Apache License, Version 2.0
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

# this file is originally from the database cookbook, preserved for legacy
# purposes until the functionality can be refactored into a custom resource.
# Original: https://github.com/chef-boneyard/database

require File.join(File.dirname(__FILE__), 'resource_database')

class Chef
  class Resource
    class DatabaseUser < Chef::Resource::Database
      resource_name :database_user
      provides :database_user

      default_action :create

      def initialize(name, run_context = nil)
        super
        @username = name

        @database_name = nil
        @table = nil
        @host = 'localhost'
        @privileges = [:all]
        @grant_option = false
        @require_ssl = false
        @require_x509 = false

        @allowed_actions.push(:create, :drop, :grant, :revoke)
      end

      property :database_name, String
      property :username, String
      property :require_ssl, [true, false]
      property :require_x509, [true, false]
      property :password, String
      property :table, String
      property :host, String
      property :privileges, Array
      property :grant_option, [true, false], default: false
    end
  end
end
