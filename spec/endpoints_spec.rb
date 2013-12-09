require_relative "spec_helper"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "endpoints"

describe ::Openstack do
  before do
    @chef_run = ::ChefSpec::Runner.new ::CHEFSPEC_OPTS
    @chef_run.converge "openstack-common::set_endpoints_by_interface"
    @subject = ::Object.new.extend ::Openstack
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
      @subject.endpoint("compute-api").to_s.should == "http://localhost"
    end
    it "returns endpoint URI object when uri key not in endpoint hash but host is in hash" do
      @subject.should_receive(:uri_from_hash).with({"host"=>"localhost", "port"=>"8080"})
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
      @subject.endpoint "compute-api"
    end
    it "endpoints recipe bind_interface sets host" do
      @subject.stub('address_for').and_return '10.0.0.100'
      chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS
      chef_run.node.set['openstack']['endpoints']['identity-api']['bind_interface'] = 'eth0'
      chef_run.node.set['network'] = {
        'interfaces' => {
          'lo' => {
            'addresses' => {
              '127.0.0.1'=> {
                'family' => 'inet',
                'netmask' => '255.0.0.0',
                'scope' => 'Node'
              }
            }
          },
          'eth0' => {
            'addresses' => {
              '10.0.0.100'=> {
                'family' => 'inet',
                'netmask' => '255.255.255.0',
                'scope' => 'Global'
              }
            }
          }
        }
      }
      chef_run.converge 'openstack-common::set_endpoints_by_interface'
      expect(chef_run.node['openstack']['endpoints']['identity-api']['host']).to eql('10.0.0.100')
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
      @count.should == 0
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
      expect = "mysql://user:pass@127.0.0.1:3306/nova?charset=utf8"
      @subject.db_uri("compute", "user", "pass").should == expect
    end
  end
end
