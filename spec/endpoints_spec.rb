# encoding: UTF-8
require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'uri'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'endpoints'

describe 'openstack-common::set_endpoints_by_interface' do
  describe 'Openstack endpoints' do
    let(:runner) { ChefSpec::Runner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }
    let(:subject) { Object.new.extend(Openstack) }

    describe '#endpoint' do
      it 'returns nil when no openstack.endpoints not in node attrs' do
        subject.stub(:node).and_return({})
        expect(
          subject.endpoint('nonexisting')
        ).to be_nil
      end

      it 'returns nil when no such endpoint was found' do
        subject.stub(:node).and_return(node)
        expect(
          subject.endpoint('nonexisting')
        ).to be_nil
      end

      it 'handles a URI needing escaped' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/v2/%(tenant_id)s'
              }
            }
          }
        }
        subject.stub(:node).and_return(uri_hash)
        expect(
          subject.endpoint('compute-api').path
        ).to eq('/v2/%25(tenant_id)s')
      end

      it 'returns endpoint URI object when uri key in endpoint hash' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              }
            }
          }
        }
        subject.stub(:node).and_return(uri_hash)
        expect(
          subject.endpoint('compute-api').port
        ).to eq(8080)
      end

      it 'returns endpoint URI string when uri key in endpoint hash and host also in hash' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost',
                'host' => 'ignored'
              }
            }
          }
        }
        subject.stub(:node).and_return(uri_hash)
        expect(subject.endpoint('compute-api').to_s).to eq('http://localhost')
      end

      it 'returns endpoint URI object when uri key not in endpoint hash but host is in hash' do
        pending 'TODO: implement'
        subject.should_receive(:uri_from_hash).with('host' => 'localhost', 'port' => '8080')
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'host' => 'localhost',
                'port' => '8080'
              }
            }
          }
        }
        subject.stub(:node).and_return(uri_hash)
        subject.endpoint 'compute-api'
      end

      it 'endpoints recipe bind_interface sets host' do
        node.set['openstack']['endpoints']['identity-api']['bind_interface'] = 'eth0'
        node.set['network'] = {
          'interfaces' => {
            'lo' => {
              'addresses' => {
                '127.0.0.1' => {
                  'family' => 'inet',
                  'netmask' => '255.0.0.0',
                  'scope' => 'Node'
                }
              }
            },
            'eth0' => {
              'addresses' => {
                '10.0.0.100' => {
                  'family' => 'inet',
                  'netmask' => '255.255.255.0',
                  'scope' => 'Global'
                }
              }
            }
          }
        }
        subject.stub('address_for').and_return('10.0.0.100')
        expect(
          chef_run.node['openstack']['endpoints']['identity-api']['host']
        ).to eq('10.0.0.100')
      end
    end

    describe '#endpoints' do
      it 'does nothing when no endpoints' do
        subject.stub(:node).and_return({})
        expect(subject.endpoints).to be_nil
      end

      it 'does nothing when empty endpoints' do
        subject.stub(:node).and_return('openstack' => { 'endpoints' => {} })
        count = 0
        subject.endpoints do | ep |
          count += 1
        end
        expect(count).to eq(0)
      end

      it 'executes block count when have endpoints' do
        subject.stub(:node).and_return(chef_run.node)
        count = 0
        subject.endpoints do |ep|
          count += 1
        end
        expect(count).to be >= 1
      end
    end

    describe '#db' do
      it 'returns nil when no openstack.db not in node attrs' do
        subject.stub(:node).and_return({})
        expect(subject.db('nonexisting')).to be_nil
      end

      it 'returns nil when no such service was found' do
        subject.stub(:node).and_return(chef_run.node)
        expect(subject.db('nonexisting')).to be_nil
      end

      it 'returns db info hash when service found' do
        subject.stub(:node).and_return(chef_run.node)
        expect(subject.db('compute')['host']).to eq('127.0.0.1')
        expect(subject.db('compute').key?('uri')).to be_false
      end
    end

    describe '#db_uri' do
      it 'returns nil when no openstack.db not in node attrs' do
        subject.stub(:node).and_return({})
        expect(subject.db_uri('nonexisting', 'user', 'pass')).to be_nil
      end

      it 'returns nil when no such service was found' do
        subject.stub(:node).and_return(chef_run.node)
        expect(
          subject.db_uri('nonexisting', 'user', 'pass')
        ).to be_nil
      end

      it 'returns compute db info hash when service found for default mysql' do
        subject.stub(:node).and_return(chef_run.node)
        expected = 'mysql://user:pass@127.0.0.1:3306/nova?charset=utf8'
        expect(
          subject.db_uri('compute', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns network db info hash when service found for sqlite with options' do
        node.set['openstack']['db']['service_type'] = 'sqlite'
        node.set['openstack']['db']['options'] = { 'sqlite' => '?options' }
        node.set['openstack']['db']['network']['path'] = 'path'
        subject.stub(:node).and_return(chef_run.node)
        expected = 'sqlite:///path?options'
        expect(
          subject.db_uri('network', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns block-storage db info hash when service found for db2 with options' do
        node.set['openstack']['db']['service_type'] = 'db2'
        node.set['openstack']['db']['options'] = { 'db2' => '?options' }
        subject.stub(:node).and_return(chef_run.node)
        expected = 'ibm_db_sa://user:pass@127.0.0.1:3306/cinder?options'
        expect(
          subject.db_uri('block-storage', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns telemetry db info hash when service found for db2' do
        node.set['openstack']['db']['service_type'] = 'db2'
        node.set['openstack']['db']['telemetry']['nosql']['used'] = true
        subject.stub(:node).and_return(chef_run.node)
        expected = 'db2://user:pass@127.0.0.1:27017/ceilometer'
        expect(
          subject.db_uri('telemetry', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns telemetry db info hash when service found for db2 with options' do
        node.set['openstack']['db']['service_type'] = 'db2'
        node.set['openstack']['db']['options'] = { 'nosql' => '?options' }
        node.set['openstack']['db']['telemetry']['nosql']['used'] = true
        subject.stub(:node).and_return(chef_run.node)
        expected = 'db2://user:pass@127.0.0.1:27017/ceilometer?options'
        expect(
          subject.db_uri('telemetry', 'user', 'pass')
        ).to eq(expected)
      end
    end

    describe '#address' do
      it 'returns interface IP if bind_interface specified' do
        ep_hash = {
          'bind_interface' => 'eth0',
          'host' => '5.6.7.8'
        }
        subject.stub('address_for').and_return('1.2.3.4')
        expect(
          subject.address(ep_hash)
        ).to eq('1.2.3.4')
      end
      it 'returns host IP if bind_interface not specified' do
        ep_hash = {
          'bind_interface' => nil,
          'host' => '5.6.7.8'
        }
        subject.stub('address_for').and_return('1.2.3.4')
        expect(
          subject.address(ep_hash)
        ).to eq('5.6.7.8')
      end
    end
  end
end
