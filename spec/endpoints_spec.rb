require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'uri'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'endpoints'

describe 'openstack-common::default' do
  describe 'Openstack endpoints' do
    let(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end
    let(:subject) { Object.new.extend(Openstack) }

    %w(public internal).each do |ep_type|
      describe "#{ep_type}_endpoint" do
        it 'fails with a NoMethodError when no openstack.endpoints in node attrs' do
          allow(subject).to receive(:node).and_return({})
          expect do
            subject.send("#{ep_type}_endpoint", 'someservice')
          end.to raise_error(NoMethodError)
        end

        it 'fails with a NoMethodError when no endpoint was found' do
          allow(subject).to receive(:node).and_return(node)
          expect do
            subject.send("#{ep_type}_endpoint", 'someservice')
          end.to raise_error(NoMethodError)
        end

        it 'handles a URI needing escaped' do
          uri_hash = {
            'openstack' => {
              'endpoints' => {
                ep_type => {
                  'compute-api' => {
                    'uri' => 'http://localhost:8080/v2/%(tenant_id)s',
                  },
                },
              },
            },
          }
          allow(subject).to receive(:node).and_return(uri_hash)
          expect(
            subject.send("#{ep_type}_endpoint", 'compute-api').path
          ).to eq('/v2/%25(tenant_id)s')
        end

        it 'returns endpoint URI object when uri key in endpoint hash' do
          uri_hash = {
            'openstack' => {
              'endpoints' => {
                ep_type => {
                  'compute-api' => {
                    'uri' => 'http://localhost:1234/path',
                  },
                },
              },
            },
          }
          allow(subject).to receive(:node).and_return(uri_hash)
          expect(
            subject.send("#{ep_type}_endpoint", 'compute-api').port
          ).to eq(1234)
        end

        it 'returns endpoint URI string when uri key in endpoint hash and host also in hash' do
          uri_hash = {
            'openstack' => {
              'endpoints' => {
                ep_type => {
                  'compute-api' => {
                    'uri' => 'http://localhost',
                    'host' => 'ignored',
                  },
                },
              },
            },
          }
          allow(subject).to receive(:node).and_return(uri_hash)
          expect(subject.send("#{ep_type}_endpoint", 'compute-api').to_s).to eq('http://localhost')
        end

        it 'returns endpoint URI object when uri key not in endpoint hash but host is in hash' do
          expect(subject).to receive(:uri_from_hash).with('host' => 'localhost', 'port' => '1234')
          uri_hash = {
            'openstack' => {
              'endpoints' => {
                ep_type => {
                  'compute-api' => {
                    'host' => 'localhost',
                    'port' => '1234',
                  },
                },
              },
            },
          }
          allow(subject).to receive(:node).and_return(uri_hash)
          subject.send("#{ep_type}_endpoint", 'compute-api')
        end
      end
    end

    describe 'transport_url' do
      it do
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:get_password)
          .with('user', 'openstack')
          .and_return('mypass')
        expected = 'rabbit://openstack:mypass@127.0.0.1:5672/'
        expect(subject.rabbit_transport_url('compute')).to eq(expected)
      end

      context 'non-default mq attributes' do
        cached(:chef_run) do
          node.override['openstack']['mq']['service_type'] = 'rabbit'
          node.override['openstack']['mq']['cluster'] = true
          node.override['openstack']['mq']['compute']['rabbit']['userid'] = 'rabbit2'
          node.override['openstack']['endpoints']['mq']['port'] = 1234
          node.override['openstack']['mq']['servers'] = %w(10.0.0.1 10.0.0.2 10.0.0.3)
          node.override['openstack']['mq']['vhost'] = '/anyhost'
          runner.converge(described_recipe)
        end
        it do
          allow(subject).to receive(:node).and_return(chef_run.node)
          allow(subject).to receive(:get_password)
            .with('user', 'rabbit2')
            .and_return('mypass2')
          expected = 'rabbit://rabbit2:mypass2@10.0.0.1:1234,rabbit2:mypass2@10.0.0.2:1234,rabbit2:mypass2@10.0.0.3:1234/anyhost'
          expect(subject.rabbit_transport_url('compute')).to eq(expected)
        end
      end
    end

    describe '#db' do
      it 'returns nil when no openstack.db not in node attrs' do
        allow(subject).to receive(:node).and_return({})
        expect(subject.db('nonexisting')).to be_nil
      end

      it 'returns nil when no such service was found' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        expect(subject.db('nonexisting')).to be_nil
      end

      it 'returns db info hash when service found' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        expect(subject.db('compute')['host']).to eq('127.0.0.1')
        expect(subject.db('compute').key?('uri')).to be_falsey
      end
    end

    describe '#db_uri' do
      it 'returns nil when no openstack.db not in node attrs' do
        allow(subject).to receive(:node).and_return({})
        expect(subject.db_uri('nonexisting', 'user', 'pass')).to be_nil
      end

      it 'returns nil when no such service was found' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        expect(
          subject.db_uri('nonexisting', 'user', 'pass')
        ).to be_nil
      end

      it 'returns compute db info hash when service found for default mysql' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'mysql+pymysql://user:pass@127.0.0.1:3306/nova?charset=utf8'
        expect(
          subject.db_uri('compute', 'user', 'pass')
        ).to eq(expected)
      end

      context 'sqlite' do
        cached(:chef_run) do
          node.override['openstack']['db']['service_type'] = 'sqlite'
          node.override['openstack']['db']['options'] = { 'sqlite' => '?options' }
          node.override['openstack']['db']['network']['path'] = 'path'
          runner.converge(described_recipe)
        end
        it 'returns network db info hash when service found for sqlite with options' do
          allow(subject).to receive(:node).and_return(chef_run.node)
          expected = 'sqlite:///path?options'
          expect(
            subject.db_uri('network', 'user', 'pass')
          ).to eq(expected)
        end
      end

      it 'returns compute db info hash when service found for mariadb' do
        node.override['openstack']['db']['service_type'] = 'mariadb'
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'mysql+pymysql://user:pass@127.0.0.1:3306/nova?charset=utf8'
        expect(
          subject.db_uri('compute', 'user', 'pass')
        ).to eq(expected)
      end

      %w(galera percona-cluster).each do |db|
        it "returns compute db info hash when service found for #{db}" do
          node.override['openstack']['db']['service_type'] = db
          allow(subject).to receive(:node).and_return(chef_run.node)
          expected = 'mysql+pymysql://user:pass@127.0.0.1:3306/nova?charset=utf8'
          expect(
            subject.db_uri('compute', 'user', 'pass')
          ).to eq(expected)
        end
      end

      it 'returns compute slave db info hash when service found for default mysql' do
        node.override['openstack']['endpoints']['db']['enabled_slave'] = true
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'mysql+pymysql://user:pass@127.0.0.1:3316/nova?charset=utf8'
        expect(
          subject.db_uri('compute', 'user', 'pass', true)
        ).to eq(expected)
      end

      it 'returns image slave db info hash when service found for mariadb' do
        node.override['openstack']['db']['service_type'] = 'mariadb'
        node.override['openstack']['endpoints']['db']['enabled_slave'] = true
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'mysql+pymysql://user:pass@127.0.0.1:3316/glance?charset=utf8'
        expect(
          subject.db_uri('image', 'user', 'pass', true)
        ).to eq(expected)
      end

      %w(galera percona-cluster).each do |db|
        it "returns network slave db info hash when service found for #{db}" do
          node.override['openstack']['db']['service_type'] = db
          node.override['openstack']['endpoints']['db']['enabled_slave'] = true
          allow(subject).to receive(:node).and_return(chef_run.node)
          expected = 'mysql+pymysql://user:pass@127.0.0.1:3316/neutron?charset=utf8'
          expect(
            subject.db_uri('network', 'user', 'pass', true)
          ).to eq(expected)
        end
      end
    end
  end
end
