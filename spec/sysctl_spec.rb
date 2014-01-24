# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-common::sysctl' do
  describe 'ubuntu' do
    before do
      @chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS
      @chef_run.converge 'openstack-common::sysctl'
    end

    describe '60-openstack.conf' do
      before do
        @file = @chef_run.template '/etc/sysctl.d/60-openstack.conf'
      end

      it 'has proper owner' do
        expect(@file.owner).to eq('root')
        expect(@file.group).to eq('root')
      end

      it 'has proper modes' do
        expect(sprintf('%o', @file.mode)).to eq '644'
      end

      it 'sets the all.rp_filter' do
        match = 'net.ipv4.conf.all.rp_filter = 0'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end

      it 'sets the default.rp_filter' do
        match = 'net.ipv4.conf.default.rp_filter = 0'
        expect(@chef_run).to render_file(@file.name).with_content(match)
      end
    end
  end
end
