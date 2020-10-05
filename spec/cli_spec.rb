require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'cli'

describe 'openstack-common::default' do
  describe 'Openstack CLI' do
    let(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end
    let(:subject) { Object.new.extend(Openstack) }

    include_context 'library-stubs'

    describe 'openstack_command_env' do
      before do
        node.override['openstack']['endpoints']['public']['identity'] = {
          host: '127.0.0.1',
          scheme: 'http',
          path: '/v3',
          port: '5000',
        }
      end
      it 'returns cli enviroment' do
        allow(subject).to receive(:get_password).with(
          'user', 'name').and_return('pass')

        expect(
          subject.openstack_command_env('name', 'project', 'default', 'default')
        ).to eq(
          'OS_USERNAME' => 'name',
          'OS_PASSWORD' => 'pass',
          'OS_PROJECT_NAME' => 'project',
          'OS_USER_DOMAIN_NAME' => 'default',
          'OS_PROJECT_DOMAIN_NAME' => 'default',
          'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
          'OS_IDENTITY_API_VERSION' => '3'
        )
      end
    end

    describe 'openstack_command' do
      it 'runs openstack command' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_PROJECT_NAME' => 'project',
            'OS_USER_DOMAIN_NAME' => 'default',
            'OS_PROJECT_DOMAIN_NAME' => 'default',
            'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
            'OS_IDENTITY_API_VERSION' => 3,
          }
        allow(subject).to receive(:shell_out).with(
          %w(openstack user list),
          env: env
        ).and_return double('shell_out', exitstatus: 0, stdout: 'good', stderr: '')

        result = subject.openstack_command('openstack', 'user list', env)
        expect(result).to eq('good')
      end

      it 'runs openstack command with args' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_PROJECT_NAME' => 'project',
            'OS_USER_DOMAIN_NAME' => 'default',
            'OS_PROJECT_DOMAIN_NAME' => 'default',
            'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
            'OS_IDENTITY_API_VERSION' => 3,
          }
        allow(subject).to receive(:shell_out).with(
          %w(openstack --key1 value1 --key2 value2 --key3 user list),
          env: env
        ).and_return double('shell_out', exitstatus: 0, stdout: 'good', stderr: '')

        result = subject.openstack_command('openstack', 'user list', env, 'key1' => 'value1', 'key2' => 'value2', 'key3' => '')
        expect(result).to eq('good')
      end

      it 'runs openstack command with failure' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_PROJECT_NAME' => 'project',
            'OS_USER_DOMAIN_NAME' => 'default',
            'OS_PROJECT_DOMAIN_NAME' => 'default',
            'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
            'OS_IDENTITY_API_VERSION' => 3,
          }
        allow(subject).to receive(:shell_out).with(
          %w(openstack user list),
          env: env
        ).and_return double('shell_out', exitstatus: 123, stdout: 'fail', stderr: '')
      end
    end

    describe 'identity_uuid' do
      it 'runs identity command to query uuid' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_PROJECT_NAME' => 'project',
            'OS_USER_DOMAIN_NAME' => 'default',
            'OS_PROJECT_DOMAIN_NAME' => 'default',
            'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
            'OS_IDENTITY_API_VERSION' => 3,
          }
        allow(subject).to receive(:openstack_command).with(
          'openstack', 'user list', env, {})
        allow(subject).to receive(:prettytable_to_array).and_return(
          [{ 'name' => 'user1', 'id' => '1234567890ABCDEFGH' }])

        result = subject.identity_uuid('user', 'name', 'user1', env)
        expect(result).to eq('1234567890ABCDEFGH')
      end
    end

    describe 'image_id' do
      let(:env) do
        {
          'OS_USERNAME' => 'name',
          'OS_PASSWORD' => 'pass',
          'OS_PROJECT_NAME' => 'project',
          'OS_USER_DOMAIN_NAME' => 'default',
          'OS_PROJECT_DOMAIN_NAME' => 'default',
          'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
          'OS_IDENTITY_API_VERSION' => 3,
        }
      end

      it 'runs glance command to query valid id' do
        allow(subject).to receive(:openstack_command).with(
          'openstack', 'image list', :env, {})
        allow(subject).to receive(:prettytable_to_array).and_return(
          [{ 'ID' => '87f38e15-9737-46cc-a612-7c67ee29a24f', 'Name' => 'cirros' }])

        result = subject.image_id('cirros', :env)
        expect(result).to eq('87f38e15-9737-46cc-a612-7c67ee29a24f')
      end

      it 'runs glance command to query invalid id' do
        allow(subject).to receive(:openstack_command).with(
          'openstack', 'image list', :env, {}).and_raise(
            "No image with a name or ID of 'test' exists. (1)")

        expect { subject.image_id('test', :env) }.to raise_error(RuntimeError)
      end
    end

    describe 'network_uuid' do
      it 'runs network command to query uuid' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_PROJECT_NAME' => 'project',
            'OS_USER_DOMAIN_NAME' => 'default',
            'OS_PROJECT_DOMAIN_NAME' => 'default',
            'OS_AUTH_URL' => 'http://127.0.0.1:5000/v3',
            'OS_IDENTITY_API_VERSION' => 3,
          }
        allow(subject).to receive(:openstack_command).with(
          'openstack', 'network list', env, {})
        allow(subject).to receive(:prettytable_to_array).and_return(
          [{ 'name' => 'net1', 'id' => '1234567890ABCDEFGH' }])

        result = subject.network_uuid('network', 'name', 'net1', env)
        expect(result).to eq('1234567890ABCDEFGH')
      end
    end
  end
end
