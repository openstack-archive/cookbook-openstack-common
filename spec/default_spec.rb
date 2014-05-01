# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::default' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set['lsb']['codename'] = 'precise'

      runner.converge(described_recipe)
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
        components: ['precise-updates/icehouse', 'main'])
    end

    it 'disables openstack live updates' do
      node.set['openstack']['apt']['live_updates_enabled'] = false
      expect(chef_run).to_not add_apt_repository('openstack-ppa').with(
        uri: 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        components: ['precise-updates/icehouse', 'main'])
    end
  end
end
