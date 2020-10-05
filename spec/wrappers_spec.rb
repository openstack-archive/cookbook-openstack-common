require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'wrappers'

describe 'openstack-common::default' do
  describe 'Openstack wrappers' do
    let(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end
    let(:subject) { Object.new.extend(Openstack) }

    include_context 'library-stubs'

    describe '#recipe_included' do
      it 'returns boolean for recipe list' do
        node_hash = {
          'recipes' => 'included_recipe',
        }
        allow(subject).to receive(:node).and_return(node_hash)
        expect(subject.recipe_included?('included_recipe')).to be_truthy
        expect(subject.recipe_included?('not_included_recipe')).to be_falsey
      end
    end

    describe '#role_included' do
      it 'returns boolean for role list' do
        node_hash_true = double('node', automatic: { 'roles' => 'included_role' }, role?: true)
        node_hash_false = double('node', automatic: { 'roles' => 'included_role' }, role?: false)
        allow(subject).to receive(:node).and_return(node_hash_true)
        expect(subject.role_included?('included_role')).to be_truthy
        allow(subject).to receive(:node).and_return(node_hash_false)
        expect(subject.role_included?('not_included_role')).to be_falsey
      end
    end
  end
end
