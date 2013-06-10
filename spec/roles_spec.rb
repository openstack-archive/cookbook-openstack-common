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
      @subject.config_by_role("role1", "foo").should be_nil
    end
    it "returns section when section in node hash" do
      ::Chef::Search::Query.stub(:new)
      node = @chef_run.node
      node.run_list << "role[role1]"
      node.set['foo'] = "bar"
      @subject.stub(:node).and_return node

      @subject.config_by_role("role1", "foo").should == "bar"
    end
    it "returns nil when no such role found" do
      ::Chef::Search::Query.stub(:new).with(:search).and_return(
        [ [], nil, nil ]
      )
      node = @chef_run.node
      node.run_list << "role[role1]"
      @subject.stub(:node).and_return node
      @subject.config_by_role("role1", "bar").should be_nil
    end
    it "returns section when section in first search result" do
      ::Chef::Search::Query.stub(:new).and_return Hashie::Mash.new(
        :search => [
          [ { "foo" => "bar" } ], nil, nil
        ]
      )
      @subject.stub(:node).and_return @chef_run.node
      @subject.config_by_role("role1", "foo").should == "bar"
    end
    it "returns full node hash when search match but no section supplied" do
      ::Chef::Search::Query.stub(:new).and_return Hashie::Mash.new(
        :search => [
          [ { "foo" => "bar" } ], nil, nil
        ]
      )
      @subject.stub(:node).and_return @chef_run.node
      @subject.config_by_role("role1").should == { "foo" => "bar" }
    end
  end
end
