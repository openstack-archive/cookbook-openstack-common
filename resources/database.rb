#
# Author:: Lance Albertson (<lance@osuosl.org>)
# Cookbook:: openstack-common
# Resource:: openstack_database
#
# Copyright:: 2020-2021, Oregon State University
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

# this file is originally from the database cookbook, preserved for legacy
# purposes until the functionality can be refactored into a custom resource.
# Original: https://github.com/chef-boneyard/database

resource_name :openstack_database
provides :openstack_database
unified_mode true
default_action :create

property :service,  String, name_property: true
property :user,     String, required: true
property :pass,     String, required: true

action :create do
  service_info = db new_resource.service
  db_name = service_info['db_name']
  db_type = service_info['service_type']
  user_key = node['openstack']['db']['root_user_key']
  super_password = get_password 'db', user_key

  mariadb_database db_name do
    encoding node['openstack']['db']['charset'][db_type]
    password super_password
  end

  mariadb_user new_resource.user do
    password new_resource.pass
    database_name db_name
    host '%'
    privileges [:all]
    ctrl_password super_password
    action [:create, :grant]
  end
end

action_class do
  include ::Openstack
end
