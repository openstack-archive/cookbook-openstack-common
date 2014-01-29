# encoding: UTF-8

require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'passwords'

describe ::Openstack do
  before do
    @chef_run = ::ChefSpec::Runner.new ::CHEFSPEC_OPTS
    @chef_run.converge 'openstack-common::default'
    @subject = ::Object.new.extend(::Openstack)
  end

  describe '#secret' do
    it 'returns index param when developer_mode is true' do
      @chef_run = ::ChefSpec::Runner.new(::CHEFSPEC_OPTS) do |n|
        n.set['openstack']['developer_mode'] = true
      end
      @chef_run.converge 'openstack-common::default'
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.secret('passwords', 'nova')
      result.should == 'nova'
    end
    it 'returns databag when developer_mode is false' do
      value = { 'nova' => 'this' }
      ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return 'secret'
      ::Chef::EncryptedDataBagItem.stub(:load).with('passwords', 'nova', 'secret').and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.secret('passwords', 'nova')
      result.should == 'this'
    end
  end

  describe '#get_password_service_password' do
    it 'returns index param when developer_mode is true' do
      @chef_run = ::ChefSpec::Runner.new(::CHEFSPEC_OPTS) do |n|
        n.set['openstack']['developer_mode'] = true
      end
      @chef_run.converge 'openstack-common::default'
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.get_password('service', 'nova')
      result.should == 'nova'
    end
    it 'returns databag when developer_mode is false' do
      value = { 'nova' => 'this' }
      ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return 'secret'
      ::Chef::EncryptedDataBagItem.stub(:load).with('service_passwords', 'nova', 'secret').and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.get_password('service', 'nova')
      result.should == 'this'
    end
  end

  describe '#get_password_db_password' do
    it 'returns index param when developer_mode is true' do
      @chef_run = ::ChefSpec::Runner.new(::CHEFSPEC_OPTS) do |n|
        n.set['openstack']['developer_mode'] = true
      end
      @chef_run.converge 'openstack-common::default'
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.get_password('db', 'nova')
      result.should == 'nova'
    end
    it 'returns databag when developer_mode is false' do
      value = { 'nova' => 'this' }
      ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return 'secret'
      ::Chef::EncryptedDataBagItem.stub(:load).with('db_passwords', 'nova', 'secret').and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.get_password('db', 'nova')
      result.should == 'this'
    end
  end

  describe '#get_password_user_password' do
    it 'returns index param when developer_mode is true' do
      @chef_run = ::ChefSpec::Runner.new(::CHEFSPEC_OPTS) do |n|
        n.set['openstack']['developer_mode'] = true
      end
      @chef_run.converge 'openstack-common::default'
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.get_password('user', 'nova')
      result.should == 'nova'
    end
    it 'returns databag when developer_mode is false' do
      value = { 'nova' => 'this' }
      ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return 'secret'
      ::Chef::EncryptedDataBagItem.stub(:load).with('user_passwords', 'nova', 'secret').and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.get_password('user', 'nova')
      result.should == 'this'
    end
  end
end
