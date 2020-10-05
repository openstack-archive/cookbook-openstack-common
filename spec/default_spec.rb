require_relative 'spec_helper'

describe 'openstack-common::default' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:mq_services) { %w(bare_metal block_storage compute database image telemetry network orchestration) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    context 'update_apt_cache true' do
      cached(:chef_run) do
        node.override['openstack']['apt']['update_apt_cache'] = true
        runner.converge(described_recipe)
      end
      it 'updates apt cache before installing packages' do
        expect(chef_run).to update_apt_update 'default'
      end
    end

    it do
      expect(chef_run).to create_file('/etc/apt/apt.conf.d/confdef')
        .with(
          owner: 'root',
          group: 'root',
          mode: '644',
          content: "Dpkg::Options {\n      \"--force-confdef\";\n      \"--force-confold\";\n      }"
        )
    end

    it 'upgrades ubuntu-cloud-keyring package' do
      expect(chef_run).to upgrade_package 'ubuntu-cloud-keyring'
    end

    context 'live_updates_enabled true' do
      cached(:chef_run) do
        node.override['openstack']['apt']['live_updates_enabled'] = true
        runner.converge(described_recipe)
      end
      it 'configures openstack repository' do
        # Using cookbook(apt) LWRP custom matcher
        # https://github.com/sethvargo/chefspec#packaging-custom-matchers
        expect(chef_run).to add_apt_repository('openstack-ppa').with(
          uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
          distribution: 'bionic-updates/train',
          components: ['main'],
          cache_rebuild: true
        )
      end
    end

    context 'live_updates_enabled false' do
      cached(:chef_run) do
        node.override['openstack']['apt']['live_updates_enabled'] = false
        runner.converge(described_recipe)
      end
      it 'disables openstack live updates' do
        expect(chef_run).to_not add_apt_repository('openstack-ppa').with(
          uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
          distribution: 'bionic-updates/train',
          components: ['main']
        )
      end
    end

    it 'configures openstack proposed repository' do
      expect(chef_run).to add_apt_repository('openstack-ppa-proposed').with(
        uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        distribution: 'bionic-proposed/train',
        components: ['main'],
        cache_rebuild: true
      )
    end

    context 'is_release true' do
      cached(:chef_run) do
        node.override['openstack']['is_release'] = true
        runner.converge(described_recipe)
      end
      it 'disables openstack proposed repository' do
        expect(chef_run).to_not add_apt_repository('openstack-ppa-proposed').with(
          uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
          distribution: 'bionic-proposed/train',
          components: ['main']
        )
      end
    end

    pkgs = %w(python3 python3-dev python3-pip python3-setuptools python3-virtualenv python3-wheel virtualenv)

    it 'installs python packages' do
      expect(chef_run).to upgrade_package(pkgs)
    end

    it 'does not install the gem chef-vault by default' do
      expect(chef_run).to_not install_chef_gem('chef-vault')
    end

    context 'databag_type vault' do
      cached(:chef_run) do
        node.override['openstack']['databag_type'] = 'vault'
        runner.converge(described_recipe)
      end
      it 'installs the gem chef-vault if databag_type is vault' do
        expect(chef_run).to install_chef_gem('chef-vault').with(version: '~> 3.2')
      end
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
      cached(:chef_run) do
        rabbit_opts.each do |key, value|
          node.override['openstack']['mq']['rabbitmq'][key] = value
        end
        runner.converge(described_recipe)
      end
      rabbit_opts.each do |key, value|
        it "configures rabbit mq #{key}" do
          node.override['openstack']['mq']['rabbitmq'][key] = value
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
