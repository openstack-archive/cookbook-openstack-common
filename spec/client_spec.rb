# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::client' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    it 'installs the latest python 2' do
      expect(chef_run).to install_python_runtime('2')
    end

    it 'installs python-openstackclient 2.6' do
      expect(chef_run).to install_python_package('python-openstackclient')
        .with(version: '2.6')
    end
  end
end
