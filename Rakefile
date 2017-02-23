task default: ["test"]

task :test => [:lint, :style, :unit]

desc "Vendor the cookbooks in the Berksfile"
task :berks_prep do
  sh %{chef exec berks vendor}
end

desc "Run FoodCritic (lint) tests"
task :lint do
  sh %{chef exec foodcritic --epic-fail any --tags ~FC003 --tags ~FC023 .}
end

desc "Run RuboCop (style) tests"
task :style do
  sh %{chef exec rubocop}
end

desc "Run RSpec (unit) tests"
task :unit => :berks_prep do
  sh %{chef exec rspec --format documentation}
end

desc "Remove the berks-cookbooks directory and the Berksfile.lock"
task :clean do
  rm_rf [
    'berks-cookbooks',
    'Berksfile.lock'
  ]
end

desc "All-in-One Neutron build"
task :integration => :common_integration do
  # Noop
end

desc "Common task used by all cookbooks for integration test"
task :common_integration do
  # Use the berksfile support to make use of the existing patch clones.
  # Make a sym link from workspace/gate-cookbook-openstack-common-chef-rake-integration
  # to workspace/cookbook-openstack-common
  patch_dir = Dir.pwd
  patch_dir_berks = ENV['ZUUL_PROJECT'].split('/')[1]
  sh %(ls -la ..)
  sh %(ls -la ../..)
  sh %(sudo ln -s #{patch_dir} ../#{patch_dir_berks})

  unless Dir.exist?('../openstack-chef-repo')
    sh %(git clone --branch stable/newton --depth 1 git://github.com/openstack/openstack-chef-repo.git ../openstack-chef-repo)
  end

  Dir.chdir('../openstack-chef-repo') do
    sh %(chef exec rake integration)
  end
end
