require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'passwords'
require 'chef-vault'

describe 'openstack-common::default' do
  describe 'Passwords' do
    let(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }
    let(:subject) { Object.new.extend(Openstack) }

    include_context 'library-stubs'

    context 'stored in encrypted data bags by default' do
      describe '#secret' do
        it 'returns databag' do
          value = { 'nova' => 'this' }
          allow(Chef::EncryptedDataBagItem).to receive(:load_secret).with(
            '/etc/chef/openstack_data_bag_secret').and_return('secret')
          allow(Chef::EncryptedDataBagItem).to receive(:load).with(
            'passwords', 'nova', 'secret').and_return(value)
          expect(subject.secret('passwords', 'nova')).to eq('this')
        end
      end

      context 'using chef-vault' do
        cached(:chef_run) do
          node.override['openstack']['databag_type'] = 'vault'
          runner.converge(described_recipe)
        end
        it 'returns the data from a chef vault item' do
          allow(ChefVault::Item).to receive(:load)
            .with('vault_passwords', 'nova')
            .and_return('nova' => 'novapassword')
          expect(subject.secret('passwords', 'nova')).to eq('novapassword')
        end
      end

      describe '#get_password' do
        %w(service db user).each do |type|
          it "returns databag value for #{type}" do
            value = { 'nova' => 'this' }
            allow(Chef::EncryptedDataBagItem).to receive(:load_secret).with(
              '/etc/chef/openstack_data_bag_secret').and_return('secret')
            allow(Chef::EncryptedDataBagItem).to receive(:load).with(
              "#{type}_passwords", 'nova', 'secret').and_return(value)
            expect(subject.get_password(type, 'nova')).to eq('this')
          end
        end

        it 'returns nil for an invalid type' do
          expect(subject.get_password('invalid_type', 'nova')).to be_nil
        end

        it 'returns tokens from the secrets_data_bag' do
          bag_content = { 'nova' => 'mysecret' }
          allow(Chef::EncryptedDataBagItem).to receive(:load_secret).with(
            '/etc/chef/openstack_data_bag_secret'
          ).and_return('secret')
          allow(Chef::EncryptedDataBagItem).to receive(:load).with(
            'secrets', 'nova', 'secret'
          ).and_return(bag_content)
          expect(subject.get_password('token', 'nova')).to eq('mysecret')
        end
      end
    end

    context 'stored in standard data bags' do
      cached(:chef_run) do
        node.override['openstack']['databag_type'] = 'standard'
        runner.converge(described_recipe)
      end
      describe '#secret' do
        it 'returns databag' do
          value = { 'nova' => 'this' }
          allow(Chef::DataBagItem).to receive(:load)
            .with('passwords', 'nova').and_return(value)
          expect(subject.secret('passwords', 'nova')).to eq('this')
        end
      end

      describe '#get_password' do
        %w(service db user).each do |type|
          it "returns databag value for #{type}" do
            value = { 'nova' => 'this' }
            allow(Chef::DataBagItem).to receive(:load).with(
              "#{type}_passwords", 'nova').and_return(value)
            expect(subject.get_password(type, 'nova')).to eq('this')
          end
        end

        it 'returns nil for an invalid type' do
          expect(subject.get_password('invalid_type', 'nova')).to be_nil
        end

        it 'returns tokens from the secrets_data_bag' do
          bag_content = { 'nova' => 'mysecret' }
          allow(Chef::DataBagItem).to receive(:load).with(
            'secrets', 'nova'
          ).and_return(bag_content)
          expect(subject.get_password('token', 'nova')).to eq('mysecret')
        end
      end
    end

    context 'stored in attributes as an alternative' do
      cached(:chef_run) do
        node.override['openstack']['use_databags'] = false
        runner.converge(described_recipe)
      end

      describe '#get_password' do
        %w(service db user token).each do |type|
          it "returns the set attribute for #{type}" do
            expect(subject.get_password(type, 'compute')).to eq("compute-#{type}")
          end
        end
      end
    end
  end
end
