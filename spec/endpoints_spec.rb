# encoding: UTF-8
require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'uri'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'endpoints'

describe 'openstack-common::set_endpoints_by_interface' do
  describe 'Openstack endpoints' do
    let(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }
    let(:subject) { Object.new.extend(Openstack) }

    describe '#endpoint' do
      it 'returns nil when no openstack.endpoints not in node attrs' do
        allow(subject).to receive(:node).and_return({})
        expect(
          subject.endpoint('nonexisting')
        ).to be_nil
      end

      it 'returns nil when no such endpoint was found' do
        allow(subject).to receive(:node).and_return(node)
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
        allow(subject).to receive(:node).and_return(uri_hash)
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
        allow(subject).to receive(:node).and_return(uri_hash)
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
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.endpoint('compute-api').to_s).to eq('http://localhost')
      end

      it 'returns endpoint URI object when uri key not in endpoint hash but host is in hash' do
        skip 'TODO: implement'
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
        allow(subject).to receive(:node).and_return(uri_hash)
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
        allow(subject).to receive('address_for').and_return('10.0.0.100')
        expect(
          chef_run.node['openstack']['endpoints']['identity-api']['host']
        ).to eq('10.0.0.100')
      end
    end

    describe '#admin_endpoint' do
      it 'returns nil admin_endpoint when not exists' do
        allow(subject).to receive(:node).and_return({})
        expect(
          subject.admin_endpoint('nonexisting')
        ).to be_nil
      end

      it 'returns general endpoint no admin endpoint exists' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              }
            }
          }
        }
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.admin_endpoint('compute-api').to_s).to eq('http://localhost:8080/path')
      end

      it 'returns admin endpoint when it exists' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              },
              'admin' => {
                'compute-api' => {
                  'uri' => 'https://localhost:1234/path'
                }
              }
            }
          }
        }
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.admin_endpoint('compute-api').to_s).to eq('https://localhost:1234/path')
        # Make sure that the general endpoint didn't break
        expect(subject.endpoint('compute-api').to_s).to eq('http://localhost:8080/path')
      end

      it 'one admin endpoint not masking another' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              },
              'foo' => {
                'uri' => 'http://localhost:8080/foo'
              },
              'admin' => {
                'compute-api' => {
                  'uri' => 'https://localhost:1234/path'
                }
              }
            }
          }
        }
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.admin_endpoint('compute-api').to_s).to eq('https://localhost:1234/path')
        # Make sure that the general endpoint didn't break
        expect(subject.endpoint('compute-api').to_s).to eq('http://localhost:8080/path')
        # Make sure foo admin_endpoint is from general definition
        expect(subject.admin_endpoint('foo').to_s).to eq('http://localhost:8080/foo')
      end
    end

    describe '#public_endpoint' do
      it 'returns nil public_endpoint when not exists' do
        allow(subject).to receive(:node).and_return({})
        expect(
          subject.public_endpoint('nonexisting')
        ).to be_nil
      end

      it 'returns general endpoint no public endpoint exists' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              }
            }
          }
        }
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.public_endpoint('compute-api').to_s).to eq('http://localhost:8080/path')
      end

      it 'returns public endpoint when it exists' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              },
              'public' => {
                'compute-api' => {
                  'uri' => 'https://localhost:1234/path'
                }
              }
            }
          }
        }
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.public_endpoint('compute-api').to_s).to eq('https://localhost:1234/path')
        # Make sure that the general endpoint didn't break
        expect(subject.endpoint('compute-api').to_s).to eq('http://localhost:8080/path')
      end
    end

    describe '#internal_endpoint' do
      it 'returns nil internal_endpoint when not exists' do
        allow(subject).to receive(:node).and_return({})
        expect(
          subject.internal_endpoint('nonexisting')
        ).to be_nil
      end

      it 'returns general endpoint no internal endpoint exists' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              }
            }
          }
        }
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.internal_endpoint('compute-api').to_s).to eq('http://localhost:8080/path')
      end

      it 'returns internal endpoint when it exists' do
        uri_hash = {
          'openstack' => {
            'endpoints' => {
              'compute-api' => {
                'uri' => 'http://localhost:8080/path'
              },
              'internal' => {
                'compute-api' => {
                  'uri' => 'https://localhost:1234/path'
                }
              }
            }
          }
        }
        allow(subject).to receive(:node).and_return(uri_hash)
        expect(subject.internal_endpoint('compute-api').to_s).to eq('https://localhost:1234/path')
        # Make sure that the general endpoint didn't break
        expect(subject.endpoint('compute-api').to_s).to eq('http://localhost:8080/path')
      end
    end

    describe '#endpoints' do
      it 'does nothing when no endpoints' do
        allow(subject).to receive(:node).and_return({})
        expect(subject.endpoints).to be_nil
      end

      it 'does nothing when empty endpoints' do
        allow(subject).to receive(:node).and_return('openstack' => { 'endpoints' => {} })
        count = 0
        subject.endpoints do
          count += 1
        end
        expect(count).to eq(0)
      end

      it 'executes block count when have endpoints' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        count = 0
        subject.endpoints do
          count += 1
        end
        expect(count).to be >= 1
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
        expected = 'mysql://user:pass@127.0.0.1:3306/nova?charset=utf8'
        expect(
          subject.db_uri('compute', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns network db info hash when service found for sqlite with options' do
        node.set['openstack']['db']['service_type'] = 'sqlite'
        node.set['openstack']['db']['options'] = { 'sqlite' => '?options' }
        node.set['openstack']['db']['network']['path'] = 'path'
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'sqlite:///path?options'
        expect(
          subject.db_uri('network', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns block-storage db info hash when service found for db2 with options' do
        node.set['openstack']['db']['service_type'] = 'db2'
        node.set['openstack']['db']['options'] = { 'db2' => '?options' }
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'ibm_db_sa://user:pass@127.0.0.1:3306/cinder?options'
        expect(
          subject.db_uri('block-storage', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns telemetry db info hash when service found for db2' do
        node.set['openstack']['db']['service_type'] = 'db2'
        node.set['openstack']['db']['telemetry']['nosql']['used'] = true
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'db2://user:pass@127.0.0.1:27017/ceilometer'
        expect(
          subject.db_uri('telemetry', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns telemetry db info hash when service found for db2 with options' do
        node.set['openstack']['db']['service_type'] = 'db2'
        node.set['openstack']['db']['options'] = { 'nosql' => '?options' }
        node.set['openstack']['db']['telemetry']['nosql']['used'] = true
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'db2://user:pass@127.0.0.1:27017/ceilometer?options'
        expect(
          subject.db_uri('telemetry', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns compute db info hash when service found for mariadb' do
        node.set['openstack']['db']['service_type'] = 'mariadb'
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'mysql://user:pass@127.0.0.1:3306/nova?charset=utf8'
        expect(
          subject.db_uri('compute', 'user', 'pass')
        ).to eq(expected)
      end

      it 'returns compute db info hash when service found for galera' do
        node.set['openstack']['db']['service_type'] = 'galera'
        allow(subject).to receive(:node).and_return(chef_run.node)
        expected = 'mysql://user:pass@127.0.0.1:3306/nova?charset=utf8'
        expect(
          subject.db_uri('compute', 'user', 'pass')
        ).to eq(expected)
      end
    end

    describe '#address' do
      it 'returns interface IP if bind_interface specified' do
        ep_hash = {
          'bind_interface' => 'eth0',
          'host' => '5.6.7.8'
        }
        allow(subject).to receive('address_for').and_return('1.2.3.4')
        expect(
          subject.address(ep_hash)
        ).to eq('1.2.3.4')
      end
      it 'returns host IP if bind_interface not specified' do
        ep_hash = {
          'bind_interface' => nil,
          'host' => '5.6.7.8'
        }
        allow(subject).to receive('address_for').and_return('1.2.3.4')
        expect(
          subject.address(ep_hash)
        ).to eq('5.6.7.8')
      end
    end
  end
end
