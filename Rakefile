task default: ['test']

task test: [:syntax, :unit]

desc 'Vendor the cookbooks in the Berksfile'
task :berks_prep do
  sh %(chef exec berks vendor)
end

desc 'Run CookStyle (syntax & lint) tests'
task :syntax do
  sh %(delivery local lint)
end

desc 'Run RSpec (unit) tests'
task unit: :berks_prep do
  sh %(delivery local unit)
end

desc 'Remove the berks-cookbooks directory and the Berksfile.lock'
task :clean do
  rm_rf [
    'berks-cookbooks',
    'Berksfile.lock',
  ]
end

desc 'All-in-One Neutron build'
task integration: :common_integration do
  # Noop
end

desc 'Common task used by all cookbooks for integration test'
task :common_integration do
  # Use the berksfile support to make use of the existing patch clones.
  # Make a sym link from workspace/gate-cookbook-openstack-common-chef-rake-integration
  # to workspace/cookbook-openstack-common
  patch_dir = Dir.pwd
  patch_dir_berks = ENV['ZUUL_PROJECT'].split('/')[1]
  sh %(ls -la ..)
  sh %(ls -la ../..)
  sh %(sudo ln -s #{patch_dir} ../#{patch_dir_berks})

  unless Dir.exist?('../openstack-chef')
    sh %(git clone --depth 1 https://opendev.org/openstack/openstack-chef ../openstack-chef)
  end

  Dir.chdir('../openstack-chef') do
    sh %(chef exec rake integration)
  end
end
