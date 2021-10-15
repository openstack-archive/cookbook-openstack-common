require_relative 'spec_helper'

describe 'openstack-common::default' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
      let(:node) { runner.node }
      cached(:chef_run) do
        node.override['openstack']['release'] = 'testrelease'
        runner.converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      case p
      when REDHAT_7
        pkgs = %w(python python2-pip python2-setuptools python-devel python-virtualenv python-wheel)

        it do
          expect(chef_run).to upgrade_package('centos-release-qemu-ev')
        end

        it do
          expect(chef_run).to include_recipe('yum-epel')
        end

        it do
          expect(chef_run).to_not include_recipe('yum-centos')
        end

        it do
          expect(chef_run).to create_yum_repository('epel').with(
            exclude: 'python2-qpid-proton python2-pyngus qpid-proton-c'
          )
        end
      when REDHAT_8
        pkgs = %w(python3-pip python3-setuptools python3-virtualenv python3-wheel python36 python36-devel)

        it do
          expect(chef_run).to_not upgrade_package('centos-release-qemu-ev')
        end

        %w(yum-epel yum-centos).each do |r|
          it do
            expect(chef_run).to include_recipe(r)
          end
        end

        it do
          expect(chef_run).to create_yum_repository('epel').with(exclude: nil)
        end

        %w(powertools centos-rabbitmq).each do |repo|
          it do
            expect(chef_run).to create_yum_repository(repo).with(enabled: true)
          end
        end
      end

      it do
        expect(chef_run).to upgrade_package(pkgs)
      end

      context 'enabling RDO with gpgcheck enabled' do
        cached(:chef_run) do
          node.override['openstack']['release'] = 'testrelease'
          node.override['openstack']['yum']['rdo_enabled'] = true
          node.override['openstack']['yum']['gpgcheck'] = true
          runner.converge(described_recipe)
        end

        it do
          expect(chef_run).to add_yum_repository('RDO-testrelease').with(gpgcheck: true)
        end
      end

      context 'enabling RDO with gpgcheck disabled' do
        cached(:chef_run) do
          node.override['openstack']['release'] = 'testrelease'
          node.override['openstack']['yum']['rdo_enabled'] = true
          node.override['openstack']['yum']['gpgcheck'] = false
          runner.converge(described_recipe)
        end

        it do
          expect(chef_run).to add_yum_repository('RDO-testrelease').with(gpgcheck: false)
        end
      end

      context 'disabling RDO deps repo with is_release true' do
        cached(:chef_run) do
          node.override['openstack']['release'] = 'testrelease'
          node.override['openstack']['is_release'] = true
          runner.converge(described_recipe)
        end

        it 'does not add the RDO deps yum repository' do
          expect(chef_run).to_not add_yum_repository('RDO-testrelease-deps')
        end
      end

      context 'disabling RDO' do
        cached(:chef_run) do
          node.override['openstack']['release'] = 'testrelease'
          node.override['openstack']['yum']['rdo_enabled'] = false
          runner.converge(described_recipe)
        end

        it 'removes RDO yum repository' do
          allow(FileTest).to receive(:exist?).and_call_original
          allow(FileTest).to receive(:exist?).with('/etc/yum.repos.d/RDO-testrelease.repo').and_return(true)
          expect(chef_run).to remove_yum_repository('RDO-testrelease')
        end

        it 'does not create RDO-Manager yum repositories' do
          expect(chef_run).to_not create_remote_file('/etc/yum.repos.d/rdo-manager-release.repo')
        end
      end

      context 'disabling RDO and repo file does not exist' do
        cached(:chef_run) do
          node.override['openstack']['release'] = 'testrelease'
          node.override['openstack']['yum']['rdo_enabled'] = false
          runner.converge(described_recipe)
        end
        it 'does nothing when RDO yum repository does not exist' do
          allow(FileTest).to receive(:exist?).and_call_original
          allow(FileTest).to receive(:exist?).with('/etc/yum.repos.d/RDO-testrelease.repo').and_return(false)
          expect(chef_run).to nothing_yum_repository('RDO-testrelease')
        end
      end
    end
  end
end
