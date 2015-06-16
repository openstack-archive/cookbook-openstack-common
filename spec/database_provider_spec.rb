# encoding: UTF-8

require_relative 'spec_helper'

describe 'test-openstack-common-database::default' do
  let(:runner) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu',
                             version: '14.04',
                             log_level: :fatal,
                             step_into: ['openstack_common_database'])
  end
  let(:node) { runner.node }
  let(:chef_run) do
    node.override['openstack']['use_databags'] = false
    node.set['openstack']['db']['service'] = { service_type: 'mysql', port: 3306, db_name: 'service_db' }
    node.set['openstack']['secret']['mysqlroot']['user'] = 'root_pass'
    runner.converge(described_recipe)
  end

  it 'uses the lwrp openstack_common_database' do
    expect(chef_run).to create_openstack_common_database('service')
      .with(user: 'db_user', pass: 'db_pass')
  end

  it 'creates the database with the database resource' do
    expect(chef_run).to create_database('create database service_db')
      .with(
        provider: ::Chef::Provider::Database::Mysql,
        connection: { host: '127.0.0.1', port: 3306, username: 'root', password: 'root_pass' },
        database_name: 'service_db',
        encoding: 'utf8'
      )
  end

  it 'creates the database use with the database_user resource' do
    expect(chef_run).to create_database_user('create database user db_user')
      .with(
        provider: ::Chef::Provider::Database::MysqlUser,
        connection: { host: '127.0.0.1', port: 3306, username: 'root', password: 'root_pass' },
        username: 'db_user',
        password: 'db_pass'
      )
  end

  it 'grants database privileges to the user with the database_user resource' do
    expect(chef_run).to grant_database_user('grant database user db_user')
      .with(
        provider: ::Chef::Provider::Database::MysqlUser,
        connection: { host: '127.0.0.1', port: 3306, username: 'root', password: 'root_pass' },
        username: 'db_user',
        password: 'db_pass',
        database_name: 'service_db',
        host: '%',
        privileges: [:all]
      )
  end

  context 'postgresql' do
    before do
      node.override['openstack']['db']['service'] = { service_type: 'postgresql', port: 5432, db_name: 'service_postgres' }
    end

    it 'creates the database with the database resource' do
      expect(chef_run).to create_database('create database service_postgres')
        .with(
          provider: ::Chef::Provider::Database::Postgresql,
          connection: { host: '127.0.0.1', port: 5432, username: 'postgres', password: 'root_pass' },
          database_name: 'service_postgres',
          encoding: 'DEFAULT'
        )
    end

    it 'creates the database use with the database_user resource' do
      expect(chef_run).to create_database_user('create database user db_user')
        .with(
          provider: ::Chef::Provider::Database::PostgresqlUser,
          connection: { host: '127.0.0.1', port: 5432, username: 'postgres', password: 'root_pass' },
          username: 'db_user',
          password: 'db_pass'
        )
    end

    it 'grants database privileges to the user with the database_user resource' do
      expect(chef_run).to grant_database_user('grant database user db_user')
        .with(
          provider: ::Chef::Provider::Database::PostgresqlUser,
          connection: { host: '127.0.0.1', port: 5432, username: 'postgres', password: 'root_pass' },
          username: 'db_user',
          password: 'db_pass',
          database_name: 'service_postgres',
          host: '%',
          privileges: [:all]
        )
    end
  end

  context 'db2' do
    before do
      node.override['openstack']['db']['service'] = { service_type: 'db2', db_name: 'service_db2' }
    end
    it 'creates the database with the db2 resource' do
      pending('db2 resource is currently only available from an IBM internal cookbook')
      expect(chef_run).to create_db2_database('create database service_db2')
        .with(
          database_name: 'service_db'
        )
    end

    it 'creates the database use with the db2_user resource' do
      pending('db2 resource is currently only available from an IBM internal cookbook')
      expect(chef_run).to create_database_user('create database user db_user')
        .with(
          db_user: 'db_user',
          db_pass: 'db_pass',
          db_name: 'service_db2'
        )
    end
  end

  context 'galera' do
    before do
      node.override['openstack']['db']['service'] = { service_type: 'galera', port: 3306, db_name: 'service_db' }
    end
  end
end
