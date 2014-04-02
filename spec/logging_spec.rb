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

      context 'logging ignore' do
        it 'adds loggers keys ignore' do
          node.set['openstack']['logging']['ignore'] = {
            'ignore.key.1' => 'ignore.value.1',
            'ignore.key.2' => 'ignore.value.2'
          }
          [
            /^\[loggers\]$/,
            /^keys=.*ignore_key_1,ignore_key_2$/
          ].each do |content|
            expect(chef_run).to render_file(file.name).with_content(content)
          end
        end

        it 'adds specific logger ignore block' do
          node.set['openstack']['logging']['ignore'] = {
            'test.nova.api.openstack.wsgi' => 'WARNING'
          }

          [
            /^\[logger_test_nova_api_openstack_wsgi\]$/,
            /^level = WARNING$/,
            /^handlers = prod,debug$/,
            /^qualname = test.nova.api.openstack.wsgi$/
          ].each do |content|
            expect(chef_run).to render_file(file.name).with_content(content)
          end
        end
      end
    end
  end
end
