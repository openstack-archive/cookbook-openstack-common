# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-common::ceph_client' do
  describe 'ubuntu' do
    before do
      opts = ::UBUNTU_OPTS.merge(step_into: ['apt_repository'])
      @chef_run = ::ChefSpec::Runner.new(opts) do |n|
        n.set['openstack']['ceph']['global']['fsid'] = '9e5038a9-4329-4cad-8c24-0813a49d1125'
        n.set['openstack']['ceph']['global']['mon_initial_members'] = %w{ 10.0.1.10 10.0.1.20 }
        n.set['openstack']['ceph']['global']['mon_hosts'] = %w{ mon01 mon02 }
        n.set['lsb']['codename'] = 'precise'
      end
      @filename = '/etc/ceph/ceph.conf'
      @chef_run.converge 'openstack-common::ceph_client'
    end

    it 'configures ceph repository' do
      file = '/etc/apt/sources.list.d/ceph.list'
      expected = 'deb     http://ceph.com/debian-emperor precise main'

      expect(@chef_run).to render_file(file).with_content(expected)
    end

    it 'creates the /etc/ceph/ceph.conf file' do
      expect(@chef_run).to create_template(@filename).with(
        owner: 'root',
        group: 'root',
        mode: '644'
      )
    end

    it 'configures ceph.conf' do
      [/^\[global\]$/,
       /^fsid = 9e5038a9-4329-4cad-8c24-0813a49d1125$/,
       /^mon_initial_members = 10.0.1.10, 10.0.1.20$/,
       /^mon_hosts = mon01, mon02$/].each do |content|
        expect(@chef_run).to render_file(@filename).with_content(content)
      end
    end

  end
end
