# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-common::openrc' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    include_context 'common-stubs'

    describe '/root/openrc' do
      let(:file) { chef_run.template('/root/openrc') }

      it 'creates the /root/openrc file' do
        expect(chef_run).to create_template(file.name).with(
          user: 'root',
          group: 'root',
          mode: 0600
        )
      end

      it 'contains auth environment variables' do
        [
          /^export OS_USERNAME=admin$/,
          /^export OS_TENANT_NAME=admin$/,
          /^export OS_PASSWORD=admin$/,
          %r{^export OS_AUTH_URL=http://127.0.0.1:5000/v2.0$},
          /^export OS_REGION_NAME=RegionOne$/
        ].each do |line|
          expect(chef_run).to render_file(file.name).with_content(line)
        end
      end

      it 'templates misc_openrc array correctly' do
        node.set['openstack']['misc_openrc'] = ['export MISC1=OPTION1', 'export MISC2=OPTION2']
        expect(chef_run).to render_file(file.name).with_content(
          /^export MISC1=OPTION1$/)
        expect(chef_run).to render_file(file.name).with_content(
          /^export MISC2=OPTION2$/)
      end

      it 'contains overridden auth environment variables' do
        node.set['openstack']['identity']['admin_tenant_name'] = 'admin-tenant-name-override'
        node.set['openstack']['identity']['admin_user'] = 'admin-user-override'
        [
          /^export OS_USERNAME=admin-user-override$/,
          /^export OS_TENANT_NAME=admin-tenant-name-override$/
        ].each do |line|
          expect(chef_run).to render_file(file.name).with_content(line)
        end
      end
    end
  end
end
