require_relative 'spec_helper'

describe 'openstack-common::client' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
      let(:node) { runner.node }
      cached(:chef_run) do
        runner.converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      case p
      when REDHAT_7
        it do
          expect(chef_run).to upgrade_package('python-openstackclient')
        end
      when REDHAT_8
        it do
          expect(chef_run).to upgrade_package('python3-openstackclient')
        end
      end
    end
  end
end
