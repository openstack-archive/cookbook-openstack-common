# encoding: UTF-8

describe 'openstack-common::default' do
  describe 'rhel-rdo' do
    before do
      @chef_run = ::ChefSpec::Runner.new(::REDHAT_OPTS) do |n|
        n.set['openstack']['release'] = 'testrelease'
      end
      @chef_run.converge 'openstack-common::default'
    end

    it 'configures RDO yum repository' do
      repo_name = 'RDO-testrelease'
      expect(@chef_run).to add_yum_repository(repo_name)
    end
  end

  describe 'rhel-no-rdo' do
    before do
      @chef_run = ::ChefSpec::Runner.new(::REDHAT_OPTS) do |n|
        n.set['openstack']['release'] = 'testrelease'
        n.set['openstack']['yum']['rdo_enabled'] = false
      end
      @chef_run.converge 'openstack-common::default'
    end

    it 'configures RDO yum repository' do
      repo_name = 'RDO-testrelease'
      expect(@chef_run).to remove_yum_repository(repo_name)
    end
  end
end
