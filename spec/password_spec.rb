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

    context 'stored in data bags by default' do
      describe '#secret' do
        it 'returns databag' do
          value = { 'nova' => 'this' }
          ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
          ::Chef::EncryptedDataBagItem.stub(:load).with('passwords', 'nova', 'secret').and_return(value)
          expect(subject.secret('passwords', 'nova')).to eq('this')
        end
      end

      describe '#get_secret' do
        it 'returns databag value' do
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

      describe '#get_password' do
        ['service', 'db', 'user'].each do |type|
          it "returns databag value for #{type}" do
            value = { 'nova' => 'this' }
            ::Chef::EncryptedDataBagItem.stub(:load_secret).with('/etc/chef/openstack_data_bag_secret').and_return('secret')
            ::Chef::EncryptedDataBagItem.stub(:load).with("#{type}_passwords", 'nova', 'secret').and_return(value)
            expect(subject.get_password(type, 'nova')).to eq('this')
          end
        end

        it 'returns nil for an invalid type' do
          expect(subject.get_password('invalid_type', 'nova')).to be_nil
        end

        it 'returns tokens from the secrets_data_bag' do
          bag_content = { 'nova' => 'mysecret' }
          ::Chef::EncryptedDataBagItem.stub(:load_secret).with(
            '/etc/chef/openstack_data_bag_secret').and_return('secret')
          ::Chef::EncryptedDataBagItem.stub(:load).with(
            'secrets', 'nova', 'secret').and_return(bag_content)
          expect(subject.get_password('token', 'nova')).to eq('mysecret')
        end
      end
    end

    context 'stored in attributes as an alternative' do
      before { node.set['openstack']['use_databags'] = false }

      describe '#get_password' do
        %w{service db user token}.each do |type|
          it "returns the set attribute for #{type}" do
            expect(subject.get_password(type, 'compute')).to eq("compute-#{type}")
          end
        end
      end
    end

    describe 'developer_mode' do
      before { node.set['openstack']['developer_mode'] = true }

      describe '#secret' do
        it 'returns index param' do
          expect(subject.secret('passwords', 'nova')).to eq('nova')
        end

        it 'returns the specified password' do
          node.override['openstack']['secret']['nova'] = '12345'
          expect(subject.secret('passwords', 'nova')).to eq('12345')
        end
      end

      describe '#get_secret' do
        it 'returns index param' do
          expect(subject.get_secret('nova')).to eq('nova')
        end

        it 'returns the specified password' do
          node.override['openstack']['secret']['nova'] = '67890'
          expect(subject.get_secret('nova')).to eq('67890')
        end
      end

      describe '#get_password' do
        ['service', 'db', 'user'].each do |type|
          it "returns index param for #{type}" do
            expect(subject.get_password(type, 'nova')).to eq('nova')
          end
        end
      end
    end
  end
end
