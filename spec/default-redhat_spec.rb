# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::default' do
  describe 'rhel-rdo' do
    let(:runner) { ChefSpec::Runner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set['openstack']['release'] = 'testrelease'

      runner.converge(described_recipe)
    end

    context 'enabling RDO' do
      before do
        node.set['openstack']['yum']['rdo_enabled'] = true
      end

      it 'adds RDO yum repository' do
        # Using cookbook(yum) LWRP custom matcher
        # https://github.com/sethvargo/chefspec#packaging-custom-matchers
        expect(chef_run).to add_yum_repository('RDO-testrelease')
      end

      it 'includes yum-epel recipe' do
        expect(chef_run).to include_recipe('yum-epel')
      end
    end

    context 'disabling RDO' do
      before do
        node.set['openstack']['yum']['rdo_enabled'] = false
      end

      it 'removes RDO yum repository' do
        ::FileTest.stub(:exist?).with('/etc/yum.repos.d/RDO-testrelease.repo').and_return(true)

        # Using cookbook(yum) LWRP custom matcher
        # https://github.com/sethvargo/chefspec#packaging-custom-matchers
        expect(chef_run).to remove_yum_repository('RDO-testrelease')
      end

      it 'does nothing when RDO yum repository does not exist' do
        repo = chef_run.find_resource('yum_repository', 'RDO-testrelease')
        expect(repo.performed_actions).to be_empty
      end

      it 'does not include yum-epel recipe' do
        expect(chef_run).to_not include_recipe('yum-epel')
      end
    end
  end
end
