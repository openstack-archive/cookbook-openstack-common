require "chefspec"
require "uri"
require ::File.join ::File.dirname(__FILE__), "..", "libraries", "uri"

describe ::Openstack do
  before do
    @subject = ::Object.new.extend(::Openstack)
  end

  describe "#uri_from_hash" do
    it "returns nil when no host or uri key found" do
      hash = {
        "port" => 8888,
        "path" => "/path"
      }
      @subject.uri_from_hash(hash).should be_nil
    end
    it "returns uri when uri key found, ignoring other parts" do
      uri = "http://localhost/"
      hash = {
        "port" => 8888,
        "path" => "/path",
        "uri"  => uri
      }
      result = @subject.uri_from_hash(hash)
      result.should be_a URI
      result.to_s.should == uri
    end
    it "constructs from host" do
      uri = "https://localhost:8888/path"
      hash = {
        "scheme" => 'https',
        "port"   => 8888,
        "path"   => "/path",
        "host"   => "localhost"
      }
      result = @subject.uri_from_hash(hash)
      result.to_s.should == uri
    end
    it "constructs with defaults" do
      uri = "https://localhost"
      hash = {
        "scheme" => 'https',
        "host"   => "localhost"
      }
      result = @subject.uri_from_hash(hash)
      result.to_s.should == uri
    end
    it "constructs with extraneous keys" do
      uri = "http://localhost"
      hash = {
        "host"    => "localhost",
        "network" => "public"  # To emulate the osops-utils::ip_location way...
      }
      result = @subject.uri_from_hash(hash)
      result.to_s.should == uri
    end
  end
end
