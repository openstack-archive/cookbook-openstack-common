require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.log_level = :warn
end

UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '18.04',
}.freeze

REDHAT_OPTS = {
  platform: 'redhat',
  version: '7',
}.freeze

# We set a default platform for non-platform specific test cases
CHEFSPEC_OPTS = UBUNTU_OPTS

shared_context 'library-stubs' do
  before do
    allow(subject).to receive(:node).and_return(chef_run.node)
  end
end

shared_context 'common-stubs' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:search_for)
      .with('os-identity').and_return(
        [{
          'openstack' => {
            'identity' => {
              'admin_tenant_name' => 'admin',
              'admin_user' => 'admin',
            },
          },
        }]
      )
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin')
      .and_return('admin')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin-user-override')
      .and_return('admin-user-override')
  end
end
