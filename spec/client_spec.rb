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
      expect(chef_run).to install_python_package('python-openstackclient')
        .with(version: '3.6.0')
    end
  end
end
