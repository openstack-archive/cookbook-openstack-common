# Provider that uses the database cookbook to create the
# service's database and grant read/write access to the
# given user and password.
#
# A privileged 'super user' and password is determined from the
# underlying database cookbooks. For instance, if a MySQL database
# is used, the node['mysql']['server_root_password'] is used along
# with the 'root' (super)user.

include ::Openstack

use_inline_resources if defined?(use_inline_resources)

action :create do
  info
  create_db(@db_name, @db_prov, @connection_info, @db_type) # create database
  create_db_user(@user, @user_prov, @connection_info, @pass) # create user
  grant_db_privileges(@user, @user_prov, @connection_info, @pass, @db_name) # grant privileges
end

private

def info
  info = node['openstack']['endpoints']['db']
  service_info = db new_resource.service
  @host = service_info['host'] || info['host']
  @port = service_info['port'] || info['port']
  user_key = node['openstack']['db']['root_user_key']
  @super_password = get_password 'user', user_key
  @db_type = service_info['service_type']
  @db_name = service_info['db_name']
  @user = new_resource.user
  @pass = new_resource.pass
  db_types
  connection_info
end

def db_types
  case @db_type
  when 'postgresql', 'pgsql'
    @db_prov = ::Chef::Provider::Database::Postgresql
    @user_prov = ::Chef::Provider::Database::PostgresqlUser
    @super_user = 'postgres'
  when 'mysql', 'mariadb', 'percona-cluster', 'galera'
    @db_prov = ::Chef::Provider::Database::Mysql
    @user_prov = ::Chef::Provider::Database::MysqlUser
    @super_user = 'root'
  else
    fail "Unsupported database type #{@db_type}"
  end
end

def connection_info
  @connection_info = {
    host: @host,
    port: @port.to_i,
    username: @super_user,
    password: @super_password
  }
end

def create_db(db_name, db_prov, connection_info, db_type)
  database "create database #{db_name}" do
    provider db_prov
    connection connection_info
    database_name db_name
    encoding node['openstack']['db']['charset'][db_type]
    action :create
  end
end

def create_db_user(user, user_prov, connection_info, pass)
  database_user "create database user #{user}"  do
    provider user_prov
    connection connection_info
    username user
    password pass
    action :create
  end
end

def grant_db_privileges(user, user_prov, connection_info, pass, db_name)
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
