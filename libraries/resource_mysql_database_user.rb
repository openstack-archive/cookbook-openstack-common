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

require File.join(File.dirname(__FILE__), 'resource_database_user')
require File.join(File.dirname(__FILE__), 'provider_database_mysql_user')

class Chef
  class Resource
    class MysqlDatabaseUser < Chef::Resource::DatabaseUser
      resource_name :mysql_database_user
      provides :mysql_database_user

      def initialize(name, run_context = nil)
        super
        @provider = Chef::Provider::Database::MysqlUser
      end
      property :password, [String, HashedPassword]
    end
  end
end
