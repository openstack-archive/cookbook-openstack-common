require "chefspec"
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
      @subject.endpoint("compute-api").has_key?("uri").should be_false
    end
  end

  describe "#endpoint_uri" do
    it "returns nil when no openstack.endpoints not in node attrs" do
      @subject.instance_variable_set(:@node, {})
      @subject.endpoint_uri("nonexisting").should be_nil
    end
    it "returns nil when no such endpoint was found" do
      @subject.instance_variable_set(:@node, @chef_run.node)
      @subject.endpoint_uri("nonexisting").should be_nil
    end
    it "returns endpoint URI string when uri key in endpoint hash" do
      uri_hash = {
        "openstack" => {
          "endpoints" => {
            "compute-api" => {
              "uri" => "http://localhost"
            }
          }
        }
      }
      @subject.instance_variable_set(:@node, uri_hash)
      @subject.endpoint_uri("compute-api").should eq "http://localhost"
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
      @subject.instance_variable_set(:@node, uri_hash)
      @subject.endpoint_uri("compute-api").should eq "http://localhost"
    end
    it "returns endpoint URI string when uri key not in endpoint hash but host is in hash" do
      uri_hash = {
        "openstack" => {
          "endpoints" => {
            "compute-api" => {
              "host" => "localhost"
            }
          }
        }
      }
      ::Openstack.stub(:uri_from_hash).and_return "http://localhost"
      @subject.instance_variable_set(:@node, uri_hash)
      @subject.endpoint_uri("compute-api").should eq "http://localhost"
    end
  end
end
