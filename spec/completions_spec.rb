# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::completions' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end
  end
end
