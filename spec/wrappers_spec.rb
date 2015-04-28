# encoding: UTF-8
require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'wrappers'

describe 'Openstack wrappers' do
  let(:subject) { Object.new.extend(Openstack) }

  describe '#recipe_included' do
    it 'returns boolean for recipe list' do
      node_hash = {
        'recipes' => 'included_recipe'
      }
      allow(subject).to receive(:node).and_return(node_hash)
      expect(subject.recipe_included?('included_recipe')).to be_truthy
      expect(subject.recipe_included?('not_included_recipe')).to be_falsey
    end
  end

  describe '#role_included' do
    it 'returns boolean for role list' do
      node_hash = {
        'roles' => 'included_role'
      }
      allow(subject).to receive(:node).and_return(node_hash)
      expect(subject.role_included?('included_role')).to be_truthy
      expect(subject.role_included?('not_included_role')).to be_falsey
    end
  end
end
