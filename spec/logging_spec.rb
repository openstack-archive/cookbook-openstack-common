# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::logging' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    describe '/etc/openstack' do
      let(:dir) { chef_run.directory('/etc/openstack') }

      it 'has proper owner' do
        expect(dir.owner).to eq('root')
        expect(dir.group).to eq('root')
      end

      it 'has proper modes' do
        expect(sprintf('%o', dir.mode)).to eq '755'
      end
    end

    describe 'logging.conf' do
      let(:file) { chef_run.template('/etc/openstack/logging.conf') }

      it 'has proper owner' do
        expect(file.owner).to eq('root')
        expect(file.group).to eq('root')
      end

      it 'has proper modes' do
        expect(sprintf('%o', file.mode)).to eq '644'
      end

      it 'templates openstack.logging.ignore block' do
        node.set['openstack']['logging']['ignore'] = {
          'test.nova.api.openstack.wsgi' => 'WARNING'
        }

        tmp = [
          '[logger_test_nova_api_openstack_wsgi]',
          'level = WARNING',
          'handlers = prod,debug',
          'qualname = test.nova.api.openstack.wsgi'
        ]
        expect(chef_run).to render_file(file.name).with_content(tmp.join('
'))
      end
    end
  end
end
