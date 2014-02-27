# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-common::ceph_client' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set['openstack']['ceph']['global']['fsid'] = '9e5038a9-4329-4cad-8c24-0813a49d1125'
      node.set['openstack']['ceph']['global']['mon_initial_members'] = %w{ 10.0.1.10 10.0.1.20 }
      node.set['openstack']['ceph']['global']['mon_hosts'] = %w{ mon01 mon02 }
      node.set['lsb']['codename'] = 'precise'

      runner.converge(described_recipe)
    end
    let(:file) { chef_run.template('/etc/ceph/ceph.conf') }

    it 'configures ceph repository' do
      # Using cookbook(apt) LWRP custom matcher
      # https://github.com/sethvargo/chefspec#packaging-custom-matchers
      expect(chef_run).to add_apt_repository('ceph').with(
        uri: 'http://ceph.com/debian-emperor',
        components: ['main'],
        distribution: 'precise')
    end

    it 'creates the /etc/ceph/ceph.conf file' do
      expect(chef_run).to create_template(file.name).with(
        owner: 'root',
        group: 'root',
        mode: '644'
      )
    end

    it 'configures ceph.conf' do
      [/^\[global\]$/,
       /^fsid = 9e5038a9-4329-4cad-8c24-0813a49d1125$/,
       /^mon_initial_members = 10.0.1.10, 10.0.1.20$/,
       /^mon_hosts = mon01, mon02$/].each do |content|
        expect(chef_run).to render_file(file.name).with_content(content)
      end
    end
  end
end
