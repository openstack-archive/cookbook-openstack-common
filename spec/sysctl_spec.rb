require_relative 'spec_helper'

describe 'openstack-common::sysctl' do
  describe 'ubuntu' do
    sysctl_kv = {
      'sysctl_key1' => 'sysctl_value1',
      'sysctl_key2' => 'sysctl_value2',
    }
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      node.override['openstack']['sysctl'] = sysctl_kv
      runner.converge(described_recipe)
    end
    it do
      expect(chef_run).to apply_sysctl('sysctl_key1').with(value: 'sysctl_value1')
    end
    it do
      expect(chef_run).to apply_sysctl('sysctl_key2').with(value: 'sysctl_value2')
    end
  end
end
