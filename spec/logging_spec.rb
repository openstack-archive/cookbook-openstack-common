require "spec_helper"

describe "openstack-common::logging" do
  describe "ubuntu" do
    before do
      @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS
      @chef_run.converge "openstack-common::logging"
    end

    describe "/etc/openstack" do
      before do
        @dir = @chef_run.directory "/etc/openstack"
      end 

      it "has proper owner" do
        expect(@dir).to be_owned_by "root", "root"
      end 

      it "has proper modes" do
        expect(sprintf("%o", @dir.mode)).to eq "755"
      end 
    end 

    describe "logging.conf" do
      before do
        @file = @chef_run.template "/etc/openstack/logging.conf"
      end

      it "has proper owner" do
        expect(@file).to be_owned_by "root", "root"
      end

      it "has proper modes" do
        expect(sprintf("%o", @file.mode)).to eq "644"
      end

      it "template contents" do
        pending "TODO: implement"
      end
    end
  end
end
