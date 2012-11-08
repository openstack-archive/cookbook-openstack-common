require "chefspec"
require "hashie"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "default"

describe ::Openstack do
  before do
    @chef_run = ::ChefSpec::ChefRunner.new.converge "openstack-common::default"
    @subject = ::Object.new.extend(::Openstack)
  end

  describe "#endpoint" do
    it "returns nil when no openstack.endpoints not in node attrs" do
      @subject.instance_variable_set(:@node, {})
      @subject.endpoint("nonexisting").should be_nil
    end
    it "returns nil when no such endpoint was found" do
      @subject.instance_variable_set(:@node, @chef_run.node)
      @subject.endpoint("nonexisting").should be_nil
    end
    it "returns endpoint hash when found" do
      @subject.instance_variable_set(:@node, @chef_run.node)
      @subject.endpoint("compute-api")['host'].should == "127.0.0.1"
    end
  end
end
