# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::sysctl' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    describe '60-openstack.conf' do
      let(:file) { chef_run.template('/etc/sysctl.d/60-openstack.conf') }

      it 'has proper owner' do
        expect(file.owner).to eq('root')
        expect(file.group).to eq('root')
      end

      it 'has proper modes' do
        expect(sprintf('%o', file.mode)).to eq '644'
      end

      { 'net.ipv4.conf.all.rp_filter' => 0,
        'net.ipv4.conf.default.rp_filter' => 0 }.each do |k, v|
        it "sets the #{k}" do
          expect(chef_run).to render_file(file.name).with_content("#{k} = #{v}")
        end
      end
    end
  end
end
