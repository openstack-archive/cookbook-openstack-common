require_relative "spec_helper"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "memcache"

describe ::Openstack do
  before do
    @chef_run = ::ChefSpec::ChefRunner.new ::CHEFSPEC_OPTS
    @chef_run.converge "openstack-common::default"
    @subject = ::Object.new.extend ::Openstack
  end

  describe "#memcached_servers" do
    it "returns proper pairs" do
      nodes = [
        { "memcached" => { "listen" => "1.1.1.1" }},
        { "memcached" => { "listen" => "2.2.2.2" }},
      ]
      @subject.stub(:node).and_return @chef_run.node
      @subject.stub(:search).
        with(:node, "chef_environment:test_env AND roles:test_role").and_return nodes
      @subject.memcached_servers("test_env", "test_role").
        should == ["1.1.1.1:11211", "2.2.2.2:11211"]
    end
    it "returns proper pairs sorted" do
      nodes = [
        { "memcached" => { "listen" => "3.3.3.3" }},
        { "memcached" => { "listen" => "1.1.1.1" }},
        { "memcached" => { "listen" => "2.2.2.2" }},
      ]
      @subject.stub(:node).and_return @chef_run.node
      @subject.stub(:search).
        with(:node, "chef_environment:test_env AND roles:test_role").and_return nodes
      @subject.memcached_servers("test_env", "test_role").
        should == ["1.1.1.1:11211", "2.2.2.2:11211", "3.3.3.3:11211"]
    end
    it "returns list of servers as defined by attributes" do
      nodes = {
        "openstack" => {
          "memcache_servers" => [ "1.1.1.1:11211", "2.2.2.2:11211" ]
        }
      }
      @subject.stub(:node).and_return @chef_run.node.merge(nodes)
      @subject.memcached_servers("test_env", "test_role").
        should == ["1.1.1.1:11211", "2.2.2.2:11211"]
    end
    it "returns empty list when list of servers is empty" do
      nodes = {
        "openstack" => {
          "memcache_servers" => []
        }
      }
      @subject.stub(:node).and_return @chef_run.node.merge(nodes)
      @subject.memcached_servers("test_env", "test_role").
        should == []
    end
  end
end
