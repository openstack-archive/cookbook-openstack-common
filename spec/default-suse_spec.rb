# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::default' do
  describe 'suse' do
    let(:runner) { ChefSpec::Runner.new(SUSE_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set_unless['lsb']['description'] = 'SUSE Linux Enterprise Server 11 (x86_64)'
      node.set_unless['lsb']['release'] = '11'
      runner.converge(described_recipe)
    end

    it 'adds the openstack repository key, but not the repository' do
      Mixlib::ShellOut.stub_chain(
        new: 'rpm -qa gpg-pubkey', run_command: nil, stdout: nil,
        new: 'zypper repos --export -').and_return(
        'http://download.opensuse.org/repositories/Cloud:/OpenStack:/Icehouse/SLE_11_SP3/')

      expect(chef_run).to run_bash('add repository key')
      expect(chef_run).not_to run_execute('add repository').with(command: /zypper addrepo/)
    end

    it 'adds the repository and the key' do
      Mixlib::ShellOut.stub_chain(
        new: 'rpm -qa gpg-pubkey', run_command: nil, stdout: nil,
        new: 'zypper repos --export -').and_return('')

      expect(chef_run).to run_bash('add repository key')
      expect(chef_run).to run_execute('add repository').with(
        command: 'zypper addrepo --check '\
        "http://download.opensuse.org/repositories/Cloud:/OpenStack:/#{node['openstack']['release'].capitalize}/SLE_11_SP3/ "\
        'Cloud:OpenStack:Icehouse')
    end

    it 'does not add the repository nor the key' do
      Mixlib::ShellOut.stub_chain(
        new: 'rpm -qa gpg-pubkey', run_command: nil, stdout: nil,
        new: 'zypper repos --export -').and_return(
        'd85f9316',
        'http://download.opensuse.org/repositories/Cloud:/OpenStack:/Icehouse/SLE_11_SP3/')
      expect(chef_run).not_to run_bash('add repository key')
      expect(chef_run).not_to run_execute('add repository').with(command: /zypper addrepo/)
    end
  end
end
