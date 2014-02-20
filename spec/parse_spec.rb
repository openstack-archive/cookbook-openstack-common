# encoding: UTF-8
require_relative 'spec_helper'
require 'uri'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'parse'

describe 'Openstack parse' do
  let(:subject) { Object.new.extend(Openstack) }

  describe '#prettytable_to_array' do
    it 'returns [] when no table provided' do
      expect(
        subject.prettytable_to_array(nil)
      ).to eq([])
    end
    it 'returns [] when table provided is empty' do
      expect(
        subject.prettytable_to_array('')
      ).to eq([])
    end
    it 'returns proper array of hashes when proper table provided' do
      table =
'+---------+----------------------------------+----------------------------------+
|  tenant |              access              |              secret              |
+---------+----------------------------------+----------------------------------+
| service | 91af731b3be244beb8f30fc59b7bc96d | ce811442cfb549c39390a203778a4bf5 |
+---------+----------------------------------+----------------------------------+'
      expect(
        subject.prettytable_to_array(table)
      ).to eq(
        [{ 'tenant' => 'service',
           'access' => '91af731b3be244beb8f30fc59b7bc96d',
           'secret' => 'ce811442cfb549c39390a203778a4bf5' }])
    end
    it 'returns proper array of hashes when proper table provided including whitespace' do
      table =
'+---------+----------------------------------+----------------------------------+
|  tenant |              access              |              secret              |
+---------+----------------------------------+----------------------------------+
| service | 91af731b3be244beb8f30fc59b7bc96d | ce811442cfb549c39390a203778a4bf5 |
+---------+----------------------------------+----------------------------------+


'
      expect(
        subject.prettytable_to_array(table)
      ).to eq(
        [{ 'tenant' => 'service',
           'access' => '91af731b3be244beb8f30fc59b7bc96d',
           'secret' => 'ce811442cfb549c39390a203778a4bf5' }])
    end
    it 'returns a flatten hash when provided a Property/Value table' do
      table =
'+-----------+----------------------------------+
|  Property |              Value               |
+-----------+----------------------------------+
|   access  | 91af731b3be244beb8f30fc59b7bc96d |
|   secret  | ce811442cfb549c39390a203778a4bf5 |
| tenant_id | 429271dd1cf54b7ca921a0017524d8ea |
|  user_id  | 1c4fc229560f40689c490c5d0838fd84 |
+-----------+----------------------------------+'
      expect(
        subject.prettytable_to_array(table)
      ).to eq(
        [{ 'tenant_id' => '429271dd1cf54b7ca921a0017524d8ea',
           'access' => '91af731b3be244beb8f30fc59b7bc96d',
           'secret' => 'ce811442cfb549c39390a203778a4bf5',
           'user_id' => '1c4fc229560f40689c490c5d0838fd84' }])
    end
    it 'returns a flatten hash when provided a Property/Value table including whitespace' do
      table =
'

+-----------+----------------------------------+
|  Property |              Value               |
+-----------+----------------------------------+
|   access  | 91af731b3be244beb8f30fc59b7bc96d |
|   secret  | ce811442cfb549c39390a203778a4bf5 |
| tenant_id | 429271dd1cf54b7ca921a0017524d8ea |
|  user_id  | 1c4fc229560f40689c490c5d0838fd84 |
+-----------+----------------------------------+'
      expect(
        subject.prettytable_to_array(table)
      ).to eq(
        [{ 'tenant_id' => '429271dd1cf54b7ca921a0017524d8ea',
           'access' => '91af731b3be244beb8f30fc59b7bc96d',
           'secret' => 'ce811442cfb549c39390a203778a4bf5',
           'user_id' => '1c4fc229560f40689c490c5d0838fd84' }])
    end
  end
end
