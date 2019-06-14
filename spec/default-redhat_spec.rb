# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::default' do
  describe 'rhel-rdo' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.override['openstack']['release'] = 'testrelease'

      runner.converge(described_recipe)
    end

    it do
      expect(chef_run).to upgrade_package('centos-release-qemu-ev')
    end

    pkgs = %w(python python2-pip python2-setuptools python-devel python-virtualenv python-wheel)

    it 'installs python2 packages' do
      expect(chef_run).to upgrade_package(pkgs)
    end

    context 'enabling RDO with gpgcheck enabled' do
      before do
        node.override['openstack']['yum']['rdo_enabled'] = true
        node.override['openstack']['yum']['gpgcheck'] = true
      end

      it 'adds RDO yum repository' do
        # Using cookbook(yum) LWRP custom matcher
        # https://github.com/sethvargo/chefspec#packaging-custom-matchers
        expect(chef_run).to add_yum_repository('RDO-testrelease')
          .with(gpgcheck: true)
      end

      it 'does include yum-epel recipe' do
        expect(chef_run).to include_recipe('yum-epel')
      end
    end

    context 'enabling RDO with gpgcheck disabled' do
      before do
        node.override['openstack']['yum']['rdo_enabled'] = true
        node.override['openstack']['yum']['gpgcheck'] = false
      end

      it 'adds RDO yum repository' do
        expect(chef_run).to add_yum_repository('RDO-testrelease')
          .with(gpgcheck: false)
      end

      it 'does include yum-epel recipe' do
        expect(chef_run).to include_recipe('yum-epel')
      end
    end

    context 'disabling RDO deps repo with is_release true' do
      before do
        node.override['openstack']['is_release'] = true
      end

      it 'does not add the RDO deps yum repository' do
        expect(chef_run).to_not add_yum_repository('RDO-testrelease-deps')
      end
    end

    context 'disabling RDO' do
      before do
        node.override['openstack']['yum']['rdo_enabled'] = false
      end

      it 'removes RDO yum repository' do
        allow(FileTest).to receive(:exist?).with('/etc/yum.repos.d/RDO-testrelease.repo').and_return(true)

        # Using cookbook(yum) LWRP custom matcher
        # https://github.com/sethvargo/chefspec#packaging-custom-matchers
        expect(chef_run).to remove_yum_repository('RDO-testrelease')
      end

      it 'does nothing when RDO yum repository does not exist' do
        repo = chef_run.find_resource('yum_repository', 'RDO-testrelease')
        expect(repo.performed_actions).to be_empty
      end

      it 'does include yum-epel recipe' do
        expect(chef_run).to include_recipe('yum-epel')
      end

      it 'does not create RDO-Manager yum repositories' do
        expect(chef_run).to_not create_remote_file('/etc/yum.repos.d/rdo-manager-release.repo')
      end
    end
  end
end
