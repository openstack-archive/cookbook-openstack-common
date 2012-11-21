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

module Openstack
  # Instead of specifying the verbose node["openstack"]["endpoints"][name],
  # this shortcut allows the simpler and shorter endpoint(name)
  def endpoint(name)
    @node['openstack']['endpoints'][name]
  rescue
    nil
  end

  # Shortcut to get the full URI for an endpoint. If the "uri" key isn't
  # set in the endpoint hash, we use the Openstack::get_uri_from_mash
  # library routine from the openstack-utils cookbook to grab a URI object
  # and construct the URI object from the endpoint parts.
  def endpoint_uri(name)
    ep = endpoint(name)
    if ep && ep.has_key?("uri")
      ep["uri"]
    elsif ep
      ::Openstack::uri_from_hash(ep).to_s
    end
  end

  # Useful for iterating over the OpenStack endpoints
  def endpoints(&block)
    @node['openstack']['endpoints'].each do | name, info |
      block.call(name, info)
    end
  rescue
    nil
  end

  # Instead of specifying the verbose node["openstack"]["db"][service],
  # this shortcut allows the simpler and shorter db(service), where
  # service is one of 'compute', 'image', 'identity', 'network',
  # and 'volume'
  def db(service)
    @node['openstack']['db'][service]
  rescue
    nil
  end

  # Shortcut to get the SQLAlchemy DB URI for a named service
  def db_uri(service, user, pass)
    info = db(service)
    if info
      host = info['host']
      port = info['port'].to_s
      type = info['db_type']
      name = info['db_name']
      if type == 'postgresql'
        # Normalize to the SQLAlchemy standard db type identifier
        type = 'pgsql'
      end
      if type == 'mysql' or type == 'pgsql'
        result = "#{type}://#{user}:#{pass}@#{host}:#{port}/#{name}"
      elsif type == 'sqlite'
        # SQLite uses filepaths not db name
        path = info['path']
        result = "sqlite://#{path}"
      end
    end
  end

  # Library routine that uses the database cookbook to create the
  # service's database and grant read/write access to the
  # given user and password.
  #
  # A privileged "super user" and password is determined from the
  # underlying database cookbooks. For instance, if a MySQL database
  # is used, the node["mysql"]["server_root_password"] is used along
  # with the "root" (super)user.
  def db_create_with_user(service, user, pass)
    info = db(service)
    if info
      host = info['host']
      port = info['port'].to_s
      type = info['db_type']
      db_name = info['db_name']
      case type
      when 'postgresql', 'pgsql'
        db_prov = Chef::Provider::Database::Postgresql
        user_prov = Chef::Provider::Database::PostgresqlUser
        # See https://github.com/opscode-cookbooks/postgresql/blob/master/recipes/server.rb#L41
        super_user = 'postgres'
        super_password = @node['postgresql']['password']['postgres']
      when 'mysql'
        db_prov = Chef::Provider::Database::Mysql
        user_prov = Chef::Provider::Database::MysqlUser
        # See https://github.com/opscode-cookbooks/mysql/blob/master/recipes/server.rb#L40
        super_user = 'root'

        # For some reason, setting this to anything other than localhost fails miserably :(
        host = 'localhost'
        super_password = @node['mysql']['server_root_password']
      else
        Chef::Log.error("Unsupported database type #{type}")
      end

      connection_info = {
        :host => host,
        :port => port.to_i,
        :username => super_user,
        :password => super_password
      }

      # create database
      database "create #{db_name} database" do
        provider db_prov
        connection connection_info
        database_name db_name
        action :create
      end

      # create user
      database_user user do
        provider user_prov
        connection connection_info
        password pass
        action :create
      end

      # grant privs to user
      database_user user do
        provider user_prov
        connection connection_info
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
