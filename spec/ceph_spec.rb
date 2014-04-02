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

    it 'creates the /etc/ceph directory' do
      expect(chef_run).to create_directory('/etc/ceph').with(
        owner: 'root',
        group: 'root'
      )
    end

    context 'configuration file' do
      it 'creates the file' do
        expect(chef_run).to create_template(file.name).with(
          owner: 'root',
          group: 'root',
          mode: '644'
        )
      end

      it 'sets file contents from the global ceph configuration attributes' do
        node.set['openstack']['ceph']['global'] = {
          'key_1' => %w(value_1_1 value_1_2),
          'key_2' => 'value_2'
        }
        [/^key_1 = value_1_1, value_1_2$/,
         /^key_2 = value_2$/].each do |content|
          expect(chef_run).to render_file(file.name).with_content(content)
        end
      end
    end
    describe 'when setup_client is not set' do
      let(:chef_run) do
        node.set['openstack']['ceph']['setup_client'] = false
        node.set['lsb']['codename'] = 'precise'

        runner.converge(described_recipe)
      end

      it "doesn't add the repository or create ceph.conf" do
        expect(chef_run).not_to create_directory('/etc/ceph')
        expect(chef_run).not_to create_template('/etc/ceph/ceph.conf')
        expect(chef_run).not_to add_apt_repository('ceph')
      end
    end
  end
end
