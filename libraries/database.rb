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

module ::Openstack # rubocop:disable Documentation
  # Library routine that uses the database cookbook to create the
  # service's database and grant read/write access to the
  # given user and password.
  #
  # A privileged 'super user' and password is determined from the
  # underlying database cookbooks. For instance, if a MySQL database
  # is used, the node['mysql']['server_root_password'] is used along
  # with the 'root' (super)user.
  def db_create_with_user(service, user, pass) # rubocop:disable CyclomaticComplexity, MethodLength
    info = db service
    if info
      host = info['host']
      port = info['port'].to_s
      type = info['service_type']
      db_name = info['db_name']
      case type
      when 'postgresql', 'pgsql'
        include_recipe 'database::postgresql'
        db_prov = ::Chef::Provider::Database::Postgresql
        user_prov = ::Chef::Provider::Database::PostgresqlUser
        super_user = 'postgres'
        user_key = node['openstack']['db']['root_user_key']
        super_password = get_password 'user', user_key
      when 'mysql', 'mariadb'
        db_prov = ::Chef::Provider::Database::Mysql
        user_prov = ::Chef::Provider::Database::MysqlUser
        super_user = 'root'
        user_key = node['openstack']['db']['root_user_key']
        super_password = get_password 'user', user_key
      when 'db2'
        db2_database 'create database' do
          db_name db_name
          action :create
        end

        db2_user 'create database user' do
          db_user user
          db_pass pass
          db_name db_name
          action :create
        end

        return info
      else
        ::Chef::Log.error("Unsupported database type #{type}")
      end

      connection_info = {
        host: host,
        port: port.to_i,
        username: super_user,
        password: super_password
      }

      # create database
      database "create database #{db_name}" do
        provider db_prov
        connection connection_info
        database_name db_name
        encoding node['openstack']['db']['charset'][type]
        action :create
      end

      # create user
      database_user "create database user #{user}"  do
        provider user_prov
        connection connection_info
        username user
        password pass
        action :create
      end

      # grant privs to user
      database_user "grant database user #{user}" do
        provider user_prov
        connection connection_info
        username user
        password pass
        database_name db_name
        host '%'
        privileges [:all]
        action :grant
      end
    end
    info
  end
end
