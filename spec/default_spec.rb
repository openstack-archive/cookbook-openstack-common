# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::default' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    it 'includes apt for apt-get update' do
      node.set['openstack']['apt']['update_apt_cache'] = 'true'
      expect(chef_run).to include_recipe 'apt'
    end

    it 'doesnt include apt for apt-get update' do
      expect(chef_run).to_not include_recipe 'apt'
    end

    it 'upgrades ubuntu-cloud-keyring package' do
      expect(chef_run).to upgrade_package 'ubuntu-cloud-keyring'
    end

    it 'configures openstack repository' do
      # Using cookbook(apt) LWRP custom matcher
      # https://github.com/sethvargo/chefspec#packaging-custom-matchers
      node.set['openstack']['apt']['live_updates_enabled'] = true
      expect(chef_run).to add_apt_repository('openstack-ppa').with(
        uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        components: ['trusty-updates/juno', 'main'])
    end

    it 'disables openstack live updates' do
      node.set['openstack']['apt']['live_updates_enabled'] = false
      expect(chef_run).to_not add_apt_repository('openstack-ppa').with(
        uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        components: ['trusty-updates/juno', 'main'])
    end

    it 'does not install the gem chef-vault by default' do
      expect(chef_run).to_not install_chef_gem('chef-vault')
    end

    it 'installs the gem chef-vault if databag_type is vault' do
      node.set['openstack']['databag_type'] = 'vault'
      expect(chef_run).to install_chef_gem('chef-vault')
      .with(version: '~> 2.3')
    end

    it 'enables rabbit ha for all services' do
      node.set['openstack']['mq']['rabbitmq']['ha'] = true
      %w{block-storage compute database image telemetry network orchestration}.each do |svc|
        expect(chef_run.node['openstack']['mq'][svc]['rabbit']['ha']).to eq(true)
      end
    end

    it 'allows bind_interface override for all bind endpoints' do
      node.set['openstack']['endpoints']['bind_interface'] = 'eth1'
      %w{identity-bind identity-admin-bind compute-api-bind compute-ec2-api-bind compute-ec2-admin-bind
         compute-xvpvnc-bind compute-novnc-bind compute-vnc-bind compute-vnc-proxy-bind
         network-api-bind image-api-bind image-registry-bind block-storage-api-bind object-storage-api-bind
         telemetry-api-bind orchestration-api-bind orchestration-api-cfn-bind orchestration-api-cloudwatch-bind
         database-api-bind}.each do |endpoint|
        expect(chef_run.node['openstack']['endpoints'][endpoint]['bind_interface']).to eq('eth1')
      end
    end
  end
end
