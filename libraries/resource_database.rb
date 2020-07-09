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

require 'chef/resource'

class Chef
  class Resource
    class Database < Chef::Resource
      resource_name :database
      provides :database

      default_action :create

      def initialize(name, run_context = nil)
        super
        @database_name = name
        @allowed_actions.push(:create, :drop, :query)
      end

      property :database_name, String
      property :connection, required: true
      property :sql, [String, Proc]
      property :template, String, default: 'DEFAULT'
      property :collation, String
      property :encoding, String, default: 'DEFAULT'
      property :tablespace, String, default: 'DEFAULT'
      property :connection_limit, String, default: '-1'
      property :owner, String

      def sql_query
        if sql.is_a?(Proc)
          sql.call
        else
          sql
        end
      end
    end
  end
end
