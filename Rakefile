task default: ["test"]

task :test => [:lint, :style, :unit]

task :berks_prep do
  sh %{chef exec berks vendor}
end

task :lint do
  sh %{chef exec foodcritic --epic-fail any --tags ~FC003 --tags ~FC023 .}
end

task :style do
  sh %{chef exec rubocop}
end

task :unit => :berks_prep do
  sh %{chef exec rspec --format documentation}
end

task :clean do
  rm_rf [
    'berks-cookbooks',
    'Berksfile.lock'
  ]
end

desc "All-in-One Neutron build Infra"
task :integration do
  # Use the berksfile REPO_DEV support to make use of the existing patch clone.
  # Make a sym link from workspace/gate-cookbook-openstack-common-chef-rake-integration
  # to workspace/cookbook-openstack-common
  patch_dir = Dir.pwd
  patch_dir_berks = ENV['ZUUL_PROJECT'].split('/')[1]
  sh %(ln -s #{patch_dir} ../#{patch_dir_berks})

  sh %(git clone --depth 1 git://github.com/stackforge/openstack-chef-repo.git ../openstack-chef-repo)
  Dir.chdir('../openstack-chef-repo') do
    sh %(REPO_DEV=ON chef exec rake integration)
  end
end
