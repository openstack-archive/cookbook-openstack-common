require "chefspec"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "default"

describe "openstack-common::default" do
  before do
    @chef_run = ::ChefSpec::ChefRunner.new.converge "openstack-common::default"
  end

  describe "apt setup" do
    it "sets apt repositories correctly" do
      Chef::Recipe.any_instance.stub(:apt_repository)
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
    @chef_run = ::ChefSpec::ChefRunner.new do |n|
      n.set['mysql'] = {}
      n.set['mysql']['server_root_password'] = "password"
      n.set["openstack"]["secret"]["service_passwords_data_bag"] = "service_passwords"
      n.set["openstack"]["secret"]["db_passwords_data_bag"] = "db_passwords"
      n.set["openstack"]["secret"]["user_passwords_data_bag"] = "user_passwords"
    end
    @chef_run.converge "openstack-common::default"
    @subject = ::Object.new.extend(::Openstack)
  end

  describe "#endpoint" do
    it "returns nil when no openstack.endpoints not in node attrs" do
      @subject.stub(:node).and_return {}
      @subject.endpoint("nonexisting").should be_nil
    end
    it "returns nil when no such endpoint was found" do
      @subject.stub(:node).and_return @chef_run.node
      @subject.endpoint("nonexisting").should be_nil
    end
    it "handles a URI needing escaped" do
      uri_hash = {
        "openstack" => {
          "endpoints" => {
            "compute-api" => {
              "uri" => "http://localhost:8080/v2/%(tenant_id)s"
            }
          }
        }
      }
      @subject.stub(:node).and_return uri_hash
      result = @subject.endpoint "compute-api"
      result.path.should == "/v2/%25(tenant_id)s"
    end
    it "returns endpoint URI object when uri key in endpoint hash" do
      uri_hash = {
        "openstack" => {
          "endpoints" => {
            "compute-api" => {
              "uri" => "http://localhost:8080/path"
            }
          }
        }
      }
      @subject.stub(:node).and_return uri_hash
      result = @subject.endpoint "compute-api"
      result.port.should == 8080
    end
    it "returns endpoint URI string when uri key in endpoint hash and host also in hash" do
      uri_hash = {
        "openstack" => {
          "endpoints" => {
            "compute-api" => {
              "uri" => "http://localhost",
              "host" => "ignored"
            }
          }
        }
      }
      @subject.stub(:node).and_return uri_hash
      @subject.endpoint("compute-api").to_s.should eq "http://localhost"
    end
    it "returns endpoint URI object when uri key not in endpoint hash but host is in hash" do
      uri_hash = {
        "openstack" => {
          "endpoints" => {
            "compute-api" => {
              "host" => "localhost",
              "port" => "8080"
            }
          }
        }
      }
      @subject.stub(:node).and_return uri_hash
      result = @subject.endpoint "compute-api"
      result.port.should == 8080
    end
  end

  describe "#endpoints" do
    it "does nothing when no endpoints" do
      @subject.stub(:node).and_return {}
      @subject.endpoints.should be_nil
    end
    it "does nothing when empty endpoints" do
      @subject.stub(:node).and_return({"openstack" => { "endpoints" => {}}})
      @count = 0
      @subject.endpoints do | ep |
        @count += 1
      end
      @count.should eq 0
    end
    it "executes block count when have endpoints" do
      @subject.stub(:node).and_return @chef_run.node
      @count = 0
      @subject.endpoints do |ep|
        @count += 1
      end
      @count.should >= 1
    end
  end

  describe "#db" do
    it "returns nil when no openstack.db not in node attrs" do
      @subject.stub(:node).and_return {}
      @subject.db("nonexisting").should be_nil
    end
    it "returns nil when no such service was found" do
      @subject.stub(:node).and_return @chef_run.node
      @subject.db("nonexisting").should be_nil
    end
    it "returns db info hash when service found" do
      @subject.stub(:node).and_return @chef_run.node
      @subject.db("compute")['host'].should == "127.0.0.1"
      @subject.db("compute").has_key?("uri").should be_false
    end
  end

  describe "#db_uri" do
    it "returns nil when no openstack.db not in node attrs" do
      @subject.stub(:node).and_return {}
      @subject.db_uri("nonexisting", "user", "pass").should be_nil
    end
    it "returns nil when no such service was found" do
      @subject.stub(:node).and_return @chef_run.node
      @subject.db_uri("nonexisting", "user", "pass").should be_nil
    end
    it "returns db info hash when service found" do
      @subject.stub(:node).and_return @chef_run.node
      expect = "mysql://user:pass@127.0.0.1:3306/nova"
      @subject.db_uri("compute", "user", "pass").should eq expect
    end
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
      result = @subject.db_create_with_user("compute", "user", "pass")
      result['host'].should eq "127.0.0.1"
      result['port'].should eq "3306"
    end
  end

  describe "#secret" do
    it "returns index param when developer_mode is true" do
      @chef_run = ::ChefSpec::ChefRunner.new(:log_level => :info) do |n|
        n.set["openstack"]["developer_mode"] = true
      end
      @chef_run.converge "openstack-common::default"
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.secret("passwords", "nova")
      result.should eq "nova"
    end
    it "returns databag when developer_mode is false" do
      value = {"nova" => "this"}
      ::Chef::EncryptedDataBagItem.stub(:load).with("passwords", "nova", "/etc/chef/openstack_data_bag_secret").and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.secret("passwords", "nova")
      result.should eq "this"
    end
  end

  describe "#service_password" do
    it "returns index param when developer_mode is true" do
      @chef_run = ::ChefSpec::ChefRunner.new do |n|
        n.set["openstack"]["developer_mode"] = true
      end
      @chef_run.converge "openstack-common::default"
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.service_password("nova")
      result.should eq "nova"
    end
    it "returns databag when developer_mode is false" do
      value = {"nova" => "this"}
      ::Chef::EncryptedDataBagItem.stub(:load).with("service_passwords", "nova", "/etc/chef/openstack_data_bag_secret").and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.service_password("nova")
      result.should eq "this"
    end
  end

  describe "#db_password" do
    it "returns index param when developer_mode is true" do
      @chef_run = ::ChefSpec::ChefRunner.new do |n|
        n.set["openstack"]["developer_mode"] = true
      end
      @chef_run.converge "openstack-common::default"
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.db_password("nova")
      result.should eq "nova"
    end
    it "returns databag when developer_mode is false" do
      value = {"nova" => "this"}
      ::Chef::EncryptedDataBagItem.stub(:load).with("db_passwords", "nova", "/etc/chef/openstack_data_bag_secret").and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.db_password("nova")
      result.should eq "this"
    end
  end

  describe "#user_password" do
    it "returns index param when developer_mode is true" do
      @chef_run = ::ChefSpec::ChefRunner.new do |n|
        n.set["openstack"]["developer_mode"] = true
      end
      @chef_run.converge "openstack-common::default"
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.user_password("nova")
      result.should eq "nova"
    end
    it "returns databag when developer_mode is false" do
      value = {"nova" => "this"}
      ::Chef::EncryptedDataBagItem.stub(:load).with("user_passwords", "nova", "/etc/chef/openstack_data_bag_secret").and_return value
      @subject.stub(:node).and_return @chef_run.node
      result = @subject.user_password("nova")
      result.should eq "this"
    end
  end
end
