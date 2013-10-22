require_relative "spec_helper"

describe "openstack-common::sysctl" do
  describe "ubuntu" do
    before do
      @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS
      @chef_run.converge "openstack-common::sysctl"
    end

    describe "60-openstack.conf" do
      before do
        @file = @chef_run.template "/etc/sysctl.d/60-openstack.conf"
      end

      it "has proper owner" do
        expect(@file).to be_owned_by "root", "root"
      end

      it "has proper modes" do
        expect(sprintf("%o", @file.mode)).to eq "644"
      end

      it "sets the all.rp_filter" do
        expect(@chef_run).to create_file_with_content @file.name,
          'net.ipv4.conf.all.rp_filter = 0'
      end

      it "sets the default.rp_filter" do
        expect(@chef_run).to create_file_with_content @file.name,
          'net.ipv4.conf.default.rp_filter = 0'
      end
    end
  end
end
