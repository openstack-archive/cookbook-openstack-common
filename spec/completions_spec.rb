require_relative 'spec_helper'

describe 'openstack-common::completions' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end
    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
    it do
      expect(chef_run).to install_package('bash-completion')
    end
    it do
      expect(chef_run).to create_directory('/etc/bash_completion.d/').with(mode: '755')
    end
    it do
      expect(chef_run).to run_execute('create OSC bash completions')
        .with(
          command: 'openstack complete > /etc/bash_completion.d/osc.bash_completion',
          creates: '/etc/bash_completion.d/osc.bash_completion'
        )
    end
  end
end
