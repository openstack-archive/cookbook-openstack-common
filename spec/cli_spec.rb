# encoding: UTF-8
require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'cli'

describe 'openstack-common::default' do
  describe 'Openstack CLI' do
    let(:runner) { ChefSpec::Runner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end
    let(:subject) { Object.new.extend(Openstack) }

    include_context 'library-stubs'

    describe 'openstack_command_env' do
      it 'returns cli enviroment' do
        subject.stub(:get_password)
         .with('user', 'name')
         .and_return('pass')

        expect(
          subject.openstack_command_env('name', 'tenant')
        ).to eq(
          'OS_USERNAME' => 'name',
          'OS_PASSWORD' => 'pass',
          'OS_TENANT_NAME' => 'tenant',
          'OS_AUTH_URL' => 'http://127.0.0.1:35357/v2.0'
        )
      end
    end

    describe 'openstack_command' do
      it 'runs openstack command' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_TENANT_NAME' => 'tenant',
            'OS_AUTH_URL' => 'http://127.0.0.1:35357/v2.0'
          }
        subject.stub(:shell_out).with(
          ['keystone', 'user-list'],
          env: env
          ).and_return double('shell_out', exitstatus: 0, stdout: 'good', stderr: '')

        result = subject.openstack_command('keystone', 'user-list', env)
        expect(result).to eq('good')
      end

      it 'runs openstack command with args' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_TENANT_NAME' => 'tenant',
            'OS_AUTH_URL' => 'http://127.0.0.1:35357/v2.0'
          }
        subject.stub(:shell_out).with(
          %w(keystone user-list --key1 value1 --key2 value2),
          env: env
          ).and_return double('shell_out', exitstatus: 0, stdout: 'good', stderr: '')

        result = subject.openstack_command('keystone', 'user-list', env, 'key1' => 'value1', 'key2' => 'value2')
        expect(result).to eq('good')
      end

      it 'runs openstack command with failure' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_TENANT_NAME' => 'tenant',
            'OS_AUTH_URL' => 'http://127.0.0.1:35357/v2.0'
          }
        subject.stub(:shell_out).with(
          ['keystone', 'user-list'],
          env: env
          ).and_return double('shell_out', exitstatus: 123, stdout: 'fail', stderr: '')

        # TODO: need to figure out why this won't work.
        # expect(subject.openstack_command('keystone', 'user-list', env)).to fail
      end
    end

    describe 'identity_uuid' do
      it 'runs identity command to query uuid' do
        env =
          {
            'OS_USERNAME' => 'name',
            'OS_PASSWORD' => 'pass',
            'OS_TENANT_NAME' => 'tenant',
            'OS_AUTH_URL' => 'http://127.0.0.1:35357/v2.0'
          }
        subject.stub(:openstack_command).with('keystone', 'user-list', env, {})
        subject.stub(:prettytable_to_array)
          .and_return([{ 'name' => 'user1', 'id' => '1234567890ABCDEFGH' }])

        result = subject.identity_uuid('user', 'name', 'user1', env)
        expect(result).to eq('1234567890ABCDEFGH')
      end
    end

    describe 'image_id' do
      let(:env) do
        {
          'OS_USERNAME' => 'name',
          'OS_PASSWORD' => 'pass',
          'OS_TENANT_NAME' => 'tenant',
          'OS_AUTH_URL' => 'http://127.0.0.1:35357/v2.0'
        }
      end

      it 'runs glance command to query valid id' do
        subject.stub(:openstack_command).with('glance', 'image-show cirros', :env, {})
        subject.stub(:prettytable_to_array)
          .and_return([{ 'id' => '87f38e15-9737-46cc-a612-7c67ee29a24f', 'name' => 'cirros' }])

        result = subject.image_id('cirros', :env)
        expect(result).to eq('87f38e15-9737-46cc-a612-7c67ee29a24f')
      end

      it 'runs glance command to query invalid id' do
        subject.stub(:openstack_command).with('glance', 'image-show test', :env, {})
          .and_raise("No image with a name or ID of 'test' exists. (1)")

        expect { subject.image_id('test', :env) }.to raise_error
      end
    end
  end
end
