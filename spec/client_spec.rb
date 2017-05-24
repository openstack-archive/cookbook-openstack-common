# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::client' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    it do
      expect(chef_run).to install_python_runtime('2')
    end

    it do
      expect(chef_run).to create_python_virtualenv('/opt/osc')
        .with(system_site_packages: true)
    end

    it do
      expect(chef_run).to install_python_package('python-openstackclient')
        .with(version: '3.11.0')
    end

    it do
      expect(chef_run).to create_link('/usr/local/bin/openstack')
        .with(to: '/opt/osc/bin/openstack')
    end
  end
end
