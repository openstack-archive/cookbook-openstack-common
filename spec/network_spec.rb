require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'network'

describe 'openstack-common::default' do
  describe 'Openstack address_for and bind_address' do
    interfaces = {
      'lo' => {
        'addresses' => {
          '127.0.0.1' => {
            'family' => 'inet',
            'prefixlen' => '8',
            'netmask' => '255.0.0.0',
            'scope' => 'Node',
          },
          '::1' => {
            'family' => 'inet6',
            'prefixlen' => '128',
            'scope' => 'Node',
          },
          '2001:db8::1' => {
            'family' => 'inet6',
            'prefixlen' => '64',
            'scope' => 'Node',
          },
        },
      },
      'eth0' => {
        'addresses' => {
          '10.0.0.2' => {
            'family' => 'inet',
            'prefixlen' => '32',
            'netmask' => '255.255.255.255',
            'scope' => 'Node',
          },
          '10.0.0.3' => {
            'family' => 'inet',
            'prefixlen' => '24',
            'netmask' => '255.255.255.0',
            'scope' => 'Node',
          },
        },
      },
    }
    cached(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    cached(:node) { runner.node }
    cached(:chef_run) do
      node.automatic['network']['interfaces'] = interfaces
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

      it 'returns first ipv4 address but no virtual ips with prefixlen 32' do
        expect(
          subject.address_for('eth0', 'inet', node, true)
        ).to eq('10.0.0.3')
      end

      it 'returns first ipv4 address even if virtual and with prefixlen 32' do
        expect(
          subject.address_for('eth0', 'inet', node, false)
        ).to eq('10.0.0.2')
      end

      it 'returns 0.0.0.0 for interface "all"' do
        expect(
          subject.address_for('all')
        ).to eq('0.0.0.0')
      end
    end

    context '#address_for ipv6' do
      cached(:chef_run) do
        node.automatic['network']['interfaces'] = interfaces
        node.override['openstack']['endpoints']['family'] = 'inet6'
        runner.converge(described_recipe)
      end

      it 'returns ipv6 address' do
        expect(
          subject.address_for('lo')
        ).to eq('2001:db8::1')
      end

      it 'returns ipv6 address' do
        expect(
          subject.address_for('lo', 'inet6')
        ).to eq('2001:db8::1')
      end

      it 'returns first ipv6 address and also virtual ips with prefixlen 128' do
        expect(
          subject.address_for('lo', 'inet6', node, false)
        ).to eq('::1')
      end

      it 'returns :: for interface "all"' do
        expect(
          subject.address_for('all', 'inet6')
        ).to eq('::')
      end
    end
    describe 'bind_address' do
      describe 'mq' do
        it 'returns the host' do
          expect(
            subject.bind_address(node['openstack']['bind_service']['mq'])
          ).to eq('127.0.0.1')
        end
        context 'mq interface set' do
          cached(:chef_run) do
            node.automatic['network']['interfaces'] = interfaces
            node.override['openstack']['endpoints']['family'] = 'inet'
            node.override['openstack']['bind_service']['mq']['interface'] = 'eth0'
            runner.converge(described_recipe)
          end
          it 'returns the interface address' do
            expect(
              subject.bind_address(node['openstack']['bind_service']['mq'])
            ).to eq('10.0.0.3')
          end
        end
      end
      describe 'db' do
        it 'returns the host' do
          expect(
            subject.bind_address(node['openstack']['bind_service']['db'])
          ).to eq('127.0.0.1')
        end
        context 'interface set' do
          cached(:chef_run) do
            node.automatic['network']['interfaces'] = interfaces
            node.override['openstack']['endpoints']['family'] = 'inet'
            node.override['openstack']['bind_service']['db']['interface'] = 'eth0'
            runner.converge(described_recipe)
          end
          it 'returns the interface address' do
            expect(
              subject.bind_address(node['openstack']['bind_service']['db'])
            ).to eq('10.0.0.3')
          end
        end
      end
    end
    describe '#address_for failures' do
      it 'fails when addresses for interface is nil' do
        node.automatic['network'] = {
          'interfaces' => {
            'lo' => {
              'addresses' => nil,
            },
          },
        }
        expect { subject.address_for('lo') }
          .to raise_error(RuntimeError, 'Interface lo has no addresses assigned')
      end

      it 'fails when no addresses are avaiable for interface' do
        node.automatic['network'] = {
          'interfaces' => {
            'lo' => {
              'addresses' => {},
            },
          },
        }
        expect { subject.address_for('lo') }
          .to raise_error(RuntimeError, 'Interface lo has no addresses assigned')
      end

      it 'fails when no address is available for interface family' do
        node.automatic['network'] = {
          'interfaces' => {
            'lo' => {
              'addresses' => {
                '127.0.0.1' => {
                  'family' => 'inet',
                  'prefixlen' => '8',
                  'netmask' => '255.0.0.0',
                  'scope' => 'Node',
                },
              },
            },
          },
        }
        expect { subject.address_for('lo', 'inet6') }
          .to raise_error(RuntimeError, 'No address for family inet6 found')
      end

      it 'fails when no address is available after dropping virtual ips' do
        node.automatic['network'] = {
          'interfaces' => {
            'lo' => {
              'addresses' => {
                '127.0.0.1' => {
                  'family' => 'inet',
                  'prefixlen' => '32',
                  'netmask' => '255.255.255.255',
                  'scope' => 'Node',
                },
              },
            },
          },
        }
        expect { subject.address_for('lo', 'inet') }
          .to raise_error(RuntimeError, 'No address for family inet found')
      end
    end
  end
end
