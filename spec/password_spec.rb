# encoding: UTF-8
require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'passwords'

describe 'openstack-common::default' do
  describe 'Passwords' do
    let(:runner) { ChefSpec::Runner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }
    let(:subject) { Object.new.extend(Openstack) }

    include_context 'library-stubs'

    describe '#secret' do
      it 'returns index param when developer_mode is true' do
        node.set['openstack']['developer_mode'] = true
        expect(subject.secret('passwords', 'nova')).to eq('nova')
      end

      it 'returns the specified password when developer_mode is true' do
        node.set['openstack']['developer_mode'] = true
        node.override['openstack']['secret']['nova'] = '12345'
        expect(subject.secret('passwords', 'nova')).to eq('12345')
      end

      it 'returns databag when developer_mode is false' do
        value = { 'nova' => 'this' }
        ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
        ::Chef::EncryptedDataBagItem.stub(:load).with('passwords', 'nova', 'secret').and_return(value)
        expect(subject.secret('passwords', 'nova')).to eq('this')
      end
    end

    describe '#get_secret' do
      it 'returns index param when developer_mode is true' do
        node.set['openstack']['developer_mode'] = true
        expect(subject.get_secret('nova')).to eq('nova')
      end

      it 'returns the specified password when developer_mode is true' do
        node.set['openstack']['developer_mode'] = true
        node.override['openstack']['secret']['nova'] = '67890'
        expect(subject.get_secret('nova')).to eq('67890')
      end

      it 'returns databag when developer_mode is false' do
        value = { 'nova' => 'this' }
        ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
        ::Chef::EncryptedDataBagItem.stub(:load).with('secrets', 'nova', 'secret').and_return(value)
        expect(subject.get_secret('nova')).to eq('this')
      end

      it 'returns secret from an alternate databag when secrets_data_bag set' do
        node.set['openstack']['secret']['secrets_data_bag'] = 'myothersecrets'
        value = { 'nova' => 'this' }
        ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
        ::Chef::EncryptedDataBagItem.stub(:load).with('myothersecrets', 'nova', 'secret').and_return(value)
        expect(subject.get_secret('nova')).to eq('this')
      end
    end

    describe '#get_password_service_password' do
      it 'returns index param when developer_mode is true' do
        node.set['openstack']['developer_mode'] = true
        expect(subject.get_password('service', 'nova')).to eq('nova')
      end

      it 'returns databag when developer_mode is false' do
        value = { 'nova' => 'this' }
        ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
        ::Chef::EncryptedDataBagItem.stub(:load).with('service_passwords', 'nova', 'secret').and_return(value)
        expect(
          subject.get_password('service', 'nova')
        ).to eq('this')
      end
    end

    describe '#get_password_db_password' do
      it 'returns index param when developer_mode is true' do
        node.set['openstack']['developer_mode'] = true
        expect(
          subject.get_password('db', 'nova')
        ).to eq('nova')
      end

      it 'returns databag when developer_mode is false' do
        value = { 'nova' => 'this' }
        ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
        ::Chef::EncryptedDataBagItem.stub(:load).with('db_passwords', 'nova', 'secret').and_return(value)
        expect(
          subject.get_password('db', 'nova')
        ).to eq('this')
      end
    end

    describe '#get_password_user_password' do
      it 'returns index param when developer_mode is true' do
        node.set['openstack']['developer_mode'] = true
        expect(
          subject.get_password('user', 'nova')
        ).to eq('nova')
      end

      it 'returns databag when developer_mode is false' do
        value = { 'nova' => 'this' }
        ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
        ::Chef::EncryptedDataBagItem.stub(:load).with('user_passwords', 'nova', 'secret').and_return(value)
        expect(
          subject.get_password('user', 'nova')
        ).to eq('this')
      end
    end
  end
end
