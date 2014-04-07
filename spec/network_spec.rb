# encoding: UTF-8
require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'network'

describe 'openstack-common::default' do
  describe 'Openstack address_for' do
    let(:runner) { ChefSpec::Runner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set['network'] = {
        'interfaces' => {
          'lo' => {
            'addresses' => {
              '127.0.0.1' => {
                'family' => 'inet',
                'prefixlen' => '8',
                'netmask' => '255.0.0.0',
                'scope' => 'Node'
              },
              '::1' => {
                'family' => 'inet6',
                'prefixlen' => '128',
                'scope' => 'Node'
              }
            }
          }
        }
      }

      runner.converge(described_recipe)
    end
    let(:subject) { Object.new.extend(Openstack) }

    include_context 'library-stubs'

    describe '#address_for ipv4' do
      it 'returns ipv4 address' do
        expect(
          subject.address_for('lo')
        ).to eq('127.0.0.1')
      end

      it 'returns ipv6 address' do
        expect(
          subject.address_for('lo', 'inet6')
        ).to eq('::1')
      end
    end
    describe '#address_for ipv6' do
      it 'returns ipv6 address' do
        node.set['openstack']['endpoints']['family'] = 'inet6'
        expect(
          subject.address_for('lo')
        ).to eq('::1')
      end

      it 'returns ipv6 address' do
        expect(
          subject.address_for('lo', 'inet6')
        ).to eq('::1')
      end
    end
  end
end
