require_relative "spec_helper"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "roles"

describe ::Openstack do
  before do
    @chef_run = ::ChefSpec::ChefRunner.new ::CHEFSPEC_OPTS
    @chef_run.converge "openstack-common::default"
    @subject = ::Object.new.extend ::Openstack
  end

  describe "#config_by_role" do
    it "returns nil when section not in node hash" do
      node = @chef_run.node
      node.run_list << "role[role1]"
      @subject.stub(:node).and_return node

      expect(@subject.config_by_role("role1", "foo")).to be_nil
    end

    it "returns section when section in node hash" do
      ::Chef::Search::Query.stub(:new)
      node = @chef_run.node
      node.run_list << "role[role1]"
      node.set['foo'] = "bar"
      @subject.stub(:node).and_return node

      expect(@subject.config_by_role("role1", "foo")).to eq "bar"
    end

    it "returns nil when no such role found" do
      @subject.stub(:search_for).
        with("role1").
        and_return []
      node = @chef_run.node
      node.run_list << "role[role1]"
      @subject.stub(:node).and_return node

      expect(@subject.config_by_role("role1", "bar")).to be_nil
    end

    it "returns section when section in first search result" do
      node = { "foo" => "bar" }
      @subject.stub(:search_for).
        with("role1").
        and_return node
      @subject.stub(:node).and_return @chef_run.node

      expect(@subject.config_by_role("role1", "foo")).to eq "bar"
    end

    it "returns full node hash when search match but no section supplied" do
      node = { "foo" => "bar" }
      @subject.stub(:search_for).
        with("role1").
        and_return node
      @subject.stub(:node).and_return @chef_run.node

      expect(@subject.config_by_role("role1")).to eq("foo" => "bar")
    end
  end
end
