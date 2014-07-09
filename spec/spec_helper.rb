# encoding: UTF-8

require 'chefspec'
require 'chefspec/berkshelf'

LOG_LEVEL = :fatal
UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '12.04',
  log_level: LOG_LEVEL
}
REDHAT_OPTS = {
  platform: 'redhat',
  version: '6.5',
  log_level: LOG_LEVEL
}
SUSE_OPTS = {
  platform: 'suse',
  version: '11.03',
  log_lovel: LOG_LEVEL
}
CHEFSPEC_OPTS = {
  log_level: LOG_LEVEL
}

shared_context 'library-stubs' do
  before do
    subject.stub(:node).and_return(chef_run.node)
  end
end

at_exit { ChefSpec::Coverage.report! }
