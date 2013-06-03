require_relative "spec_helper"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "default"

describe "openstack-common::default" do
  describe "ubuntu" do
    before do
      opts = ::UBUNTU_OPTS.merge :step_into => ["apt_repository"]
      @chef_run = ::ChefSpec::ChefRunner.new(opts) do |n|
        n.set["lsb"]["codename"] = "precise"
      end
      @chef_run.converge "openstack-common::default"
    end

    it "installs ubuntu-cloud-keyring package" do
      expect(@chef_run).to install_package "ubuntu-cloud-keyring"
    end

    it "configures openstack repository" do
      file = "/etc/apt/sources.list.d/openstack-ppa.list"
      expected = "deb     http://ubuntu-cloud.archive.canonical.com/ubuntu  precise-updates/grizzly main"

      expect(@chef_run).to create_file_with_content file, expected
    end
  end
end

describe ::Openstack do
  before do
    @chef_run = ::ChefSpec::ChefRunner.new ::CHEFSPEC_OPTS
    @chef_run.converge "openstack-common::default"
    @subject = ::Object.new.extend ::Openstack
    @subject.stub :include_recipe
  end

  describe "#db_create_with_user" do
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

    it "creates database" do
      pending "TODO: test this LWRP"
    end

    it "creates database user" do
      pending "TODO: test this LWRP"
    end

    it "grants privs to database user" do
      pending "TODO: test this LWRP"
    end
  end
end
