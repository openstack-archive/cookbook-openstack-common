# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::default' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:mq_services) { %w(bare-metal block-storage compute database image telemetry network orchestration) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    it 'does not include apt for apt-get update' do
      expect(chef_run).to_not include_recipe 'apt'
    end

    it 'updates apt cache before installing packages' do
      node.override['openstack']['apt']['update_apt_cache'] = true
      expect(chef_run).to update_apt_update 'default'
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
        distribution: 'xenial-updates/queens',
        components: ['main'],
        cache_rebuild: true
      )
    end

    it 'disables openstack live updates' do
      node.set['openstack']['apt']['live_updates_enabled'] = false
      expect(chef_run).to_not add_apt_repository('openstack-ppa').with(
        uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        distribution: 'xenial-updates/queens',
        components: ['main']
      )
    end

    it 'configures openstack proposed repository' do
      expect(chef_run).to add_apt_repository('openstack-ppa-proposed').with(
        uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        distribution: 'xenial-proposed/queens',
        components: ['main'],
        cache_rebuild: true
      )
    end

    it 'disables openstack proposed repository' do
      node.override['openstack']['is_release'] = true
      expect(chef_run).to_not add_apt_repository('openstack-ppa-proposed').with(
        uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        distribution: 'xenial-proposed/queens',
        components: ['main']
      )
    end

    it 'does not install the gem chef-vault by default' do
      expect(chef_run).to_not install_chef_gem('chef-vault')
    end

    it 'installs the gem chef-vault if databag_type is vault' do
      node.set['openstack']['databag_type'] = 'vault'
      expect(chef_run).to install_chef_gem('chef-vault')
        .with(version: '~> 3.2')
    end

    context 'rabbit mq' do
      rabbit_opts = {
        'userid' => 'openstack',
        'vhost' => '/',
        'port' => '5672',
        'host' => '127.0.0.1',
        'ha' => true,
        'heartbeat_timeout_threshold' => 123,
        'heartbeat_rate' => 123,
        'kombu_ssl_version' => 'TLSv1.2',
        'kombu_ssl_keyfile' => 'key_file',
        'kombu_ssl_certfile' => 'cert_file',
        'kombu_ssl_ca_certs' => 'ca_certs_file',
        'kombu_reconnect_delay' => 123.456,
        'kombu_reconnect_timeout' => 123,
      }
      rabbit_opts.each do |key, value|
        it "configures rabbit mq #{key}" do
          node.set['openstack']['mq']['rabbitmq'][key] = value
          mq_services.each do |service|
            expect(chef_run.node['openstack']['mq'][service]['rabbit'][key]).to eq(value)
          end
        end
      end

      it 'set rabbit_max_retries to 0 for all services' do
        mq_services.each do |svc|
          expect(chef_run.node['openstack']['mq'][svc]['rabbit']['rabbit_max_retries']).to eq(0)
        end
      end

      it 'set rabbit_retry_interval to 1 for all services' do
        mq_services.each do |svc|
          expect(chef_run.node['openstack']['mq'][svc]['rabbit']['rabbit_retry_interval']).to eq(1)
        end
      end
    end
  end
end
