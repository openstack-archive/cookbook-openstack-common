# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::sysctl' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    describe 'sysctl.d directory' do
      it 'should create /etc/systctl.d' do
        expect(chef_run).to create_directory('/etc/sysctl.d')
      end
    end

    describe '60-openstack.conf' do
      let(:file) { chef_run.template('/etc/sysctl.d/60-openstack.conf') }

      it 'should create the template /etc/systctl.d/60-openstack.conf' do
        expect(chef_run).to create_template('/etc/sysctl.d/60-openstack.conf').with(
          owner: 'root',
          group: 'root',
          mode: 0644
        )
      end

      it 'sets the sysctl attributes' do
        sysctl_kv = { 'systcl_key1' => 'sysctl_value1',
                      'sysctl_key2' => 'sysctl_value2' }
        node.set['openstack']['sysctl'] = sysctl_kv
        sysctl_kv.each do |k, v|
          expect(chef_run).to render_file(file.name).with_content(/^#{k} = #{v}$/)
        end
      end
    end

    describe 'execute sysctl' do
      it 'should execute sysctl for 60-openstack' do
        resource = chef_run.execute('sysctl -p /etc/sysctl.d/60-openstack.conf')
        expect(resource).to do_nothing
        expect(resource).to subscribe_to('template[/etc/sysctl.d/60-openstack.conf]').on(:run).immediately
      end
    end
  end
end
