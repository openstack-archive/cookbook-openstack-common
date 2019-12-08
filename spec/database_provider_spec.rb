# encoding: UTF-8

require_relative 'spec_helper'

describe 'test-openstack-common-database::default' do
  let(:runner) do
    ChefSpec::SoloRunner.new(CHEFSPEC_OPTS.dup.merge(step_into: ['openstack_common_database']))
  end
  let(:node) { runner.node }
  cached(:chef_run) do
    node.override['openstack']['use_databags'] = false
    node.override['openstack']['secret']['mysqlroot']['db'] = 'root_pass'
    node.override['openstack']['db']['service'] = { service_type: 'mysql', port: 3306, db_name: 'service_db' }
    runner.converge(described_recipe)
  end

  it 'uses the lwrp openstack_common_database' do
    expect(chef_run).to create_openstack_common_database('service')
      .with(user: 'db_user', pass: 'db_pass')
  end

  context 'specific root user db endpoint' do
    cached(:chef_run) do
      node.override['openstack']['endpoints']['db']['host_for_db_root_user'] = 'localhost123'
      node.override['openstack']['use_databags'] = false
      node.override['openstack']['secret']['mysqlroot']['db'] = 'root_pass'
      node.override['openstack']['db']['service'] = { service_type: 'mysql', port: 3306, db_name: 'service_db' }
      runner.converge(described_recipe)
    end
    it 'connects to the database via a specific endpoint for the root user' do
      expect(chef_run).to create_database('create database service_db')
        .with(
          provider: ::Chef::Provider::Database::Mysql,
          connection: { host: 'localhost123', port: 3306, username: 'root', password: 'root_pass', socket: '/var/run/mysqld/mysqld.sock' },
          database_name: 'service_db',
          encoding: 'utf8'
        )
    end
  end

  it 'creates the database with the database resource' do
    expect(chef_run).to create_database('create database service_db')
      .with(
        provider: ::Chef::Provider::Database::Mysql,
        connection: { host: 'localhost', port: 3306, username: 'root', password: 'root_pass', socket: '/var/run/mysqld/mysqld.sock' },
        database_name: 'service_db',
        encoding: 'utf8'
      )
  end

  it 'creates the database use with the database_user resource' do
    expect(chef_run).to create_database_user('create database user db_user')
      .with(
        provider: ::Chef::Provider::Database::MysqlUser,
        connection: { host: 'localhost', port: 3306, username: 'root', password: 'root_pass', socket: '/var/run/mysqld/mysqld.sock' },
        username: 'db_user',
        password: 'db_pass'
      )
  end

  it 'grants database privileges to the user with the database_user resource' do
    expect(chef_run).to grant_database_user('grant database user db_user')
      .with(
        provider: ::Chef::Provider::Database::MysqlUser,
        connection: { host: 'localhost', port: 3306, username: 'root', password: 'root_pass', socket: '/var/run/mysqld/mysqld.sock' },
        username: 'db_user',
        password: 'db_pass',
        database_name: 'service_db',
        host: '%',
        privileges: [:all]
      )
  end

  context 'galera' do
    before do
      node.override['openstack']['db']['service'] = { service_type: 'galera', port: 3306, db_name: 'service_db' }
    end
  end
end
