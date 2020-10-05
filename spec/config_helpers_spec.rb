require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'config_helpers'

describe 'openstack-common::default' do
  describe 'module Openstack config_helpers' do
    let(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end
    let(:subject) { Object.new.extend(Openstack) }
    include_context 'library-stubs'
    before do
      node.override['openstack']['anyservice']['conf'] =
        {
          'Default' => { 'logfile' => 'file_to_log' },
          'secret_section' => {},
          'another_section' => { 'foo' => 'bar', 'baz' => 'yay' },
          'deep_section' => {
            'foo' => { key: 'bar', value: 'baz' },
            'baz' => 'yay',
          },
        }
      node.override['openstack']['anyservice']['conf_secrets'] =
        {
          'Default' => { 'secret_log' => 'secret_file_to_log' },
          'secret_section' => { 'password' => '1234' },
          'another_section' => { 'secret_foo' => 'secret_bar' },
          'another_secret_section' => { 'secret_baz' => 'secret_yay' },
        }
    end

    describe 'merge_config_options' do
      it ' node objects should be duped and be kind of Mash afterwards' do
        expect(
          subject.merge_config_options('anyservice')
        ).to be_a(Mash)
      end
      it 'duped node objects should be merged correctly' do
        expect(
          subject.merge_config_options('anyservice')
        ).to eq(
          'Default' => { 'logfile' => 'file_to_log', 'secret_log' => 'secret_file_to_log' },
          'secret_section' => { 'password' => '1234' },
          'another_section' => { 'foo' => 'bar', 'baz' => 'yay', 'secret_foo' => 'secret_bar' },
          'another_secret_section' => { 'secret_baz' => 'secret_yay' },
          'deep_section' => {
            'foo' => { 'key' => 'bar', 'value' => 'baz' },
            'baz' => 'yay',
          }
        )
      end
    end
  end
end
