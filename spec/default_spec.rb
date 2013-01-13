require "chefspec"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "default"

describe "openstack-common::default" do
  before do
    @chef_run = ::ChefSpec::ChefRunner.new.converge "openstack-common::default"
  end

  describe "apt setup" do
    it "sets apt repositories correctly" do
      Chef::Recipe.any_instance.stub :apt_repository
      @chef_run = ::ChefSpec::ChefRunner.new(:log_level => :info) do |n|
        n.set["platform_family"] = "debian"
        n.set["lsb"]["codename"] = "precise"
        n.set["openstack"]["release"] = "folsom"
      end
      @chef_run.converge "openstack-common::default"
      @chef_run.should install_package "ubuntu-cloud-keyring"
      @chef_run.should log "  precise-updates/folsom"
      @chef_run.should log "  main"
    end
  end
end

describe ::Openstack do
  before do
    @chef_run = ::ChefSpec::ChefRunner.new.converge "openstack-common::default"
    @subject = ::Object.new.extend ::Openstack
  end

  describe "#db_create_with_user" do
    it "returns nil when no openstack.db not in node attrs" do
      @subject.stub(:node).and_return {}
      @subject.db_create_with_user("nonexisting", "user", "pass").should be_nil
    end
    it "returns nil when no such service was found" do
      @subject.stub(:node).and_return @chef_run.node
      @subject.db_create_with_user("nonexisting", "user", "pass").should be_nil
    end
    it "returns db info and creates database with user when service found" do
      @subject.stub(:database).and_return {}
      @subject.stub(:database_user).and_return {}
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.db_create_with_user "compute", "user", "pass"
      result['host'].should == "127.0.0.1"
      result['port'].should == "3306"
    end
  end
end
