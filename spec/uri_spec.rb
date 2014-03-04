# encoding: UTF-8
require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'uri'
require 'uri'

describe 'Openstack uri' do
  let(:subject) { Object.new.extend(Openstack) }

  describe '#uri_from_hash' do
    it 'returns nil when no host or uri key found' do
      hash = {
        'port' => 8888,
        'path' => '/path'
      }
      expect(
        subject.uri_from_hash(hash)
      ).to be_nil
    end

    it 'returns uri when uri key found, ignoring other parts' do
      uri = 'http://localhost/'
      hash = {
        'port' => 8888,
        'path' => '/path',
        'uri'  => uri
      }
      result = subject.uri_from_hash(hash)
      expect(result).to be_a URI
      expect(result.to_s).to eq(uri)
    end

    it 'constructs from host' do
      uri = 'https://localhost:8888/path'
      hash = {
        'scheme' => 'https',
        'port'   => 8888,
        'path'   => '/path',
        'host'   => 'localhost'
      }
      expect(
        subject.uri_from_hash(hash).to_s
      ).to eq(uri)
    end

    it 'constructs with defaults' do
      uri = 'https://localhost'
      hash = {
        'scheme' => 'https',
        'host'   => 'localhost'
      }
      expect(
        subject.uri_from_hash(hash).to_s
      ).to eq(uri)
    end

    it 'constructs with extraneous keys' do
      uri = 'http://localhost'
      hash = {
        'host'    => 'localhost',
        'network' => 'public'  # To emulate the osops-utils::ip_location way...
      }
      expect(
        subject.uri_from_hash(hash).to_s
      ).to eq(uri)
    end
  end

  describe '#uri_join_paths' do
    it 'returns nil when no paths are passed in' do
      expect(subject.uri_join_paths).to be_nil
    end

    it 'preserves absolute path when only absolute path passed in' do
      path = '/abspath'
      expect(
        subject.uri_join_paths(path)
      ).to eq(path)
    end

    it 'preserves relative path when only relative path passed in' do
      path = 'abspath/'
      expect(
        subject.uri_join_paths(path)
      ).to eq(path)
    end

    it 'preserves leadng and trailing slashes' do
      expected = '/path/to/resource/'
      expect(
        subject.uri_join_paths('/path', 'to', 'resource/')
      ).to eq(expected)
    end

    it 'removes extraneous intermediate slashes' do
      expected = '/path/to/resource'
      expect(
        subject.uri_join_paths('/path', '//to/', '/resource')
      ).to eq(expected)
    end
  end

  describe '#auth_uri_transform' do
    it 'preserves the original auth uri when the auth version passed is v2.0' do
      auth_version = 'v2.0'
      auth_uri = 'http://localhost:5000/v2.0'
      expect(
        subject.auth_uri_transform(auth_uri, auth_version)
      ).to eq(auth_uri)
    end

    it 'substitute /v2.0 with /v3 in the passed auth uri when auth version passed is v3.0' do
      auth_version = 'v3.0'
      auth_uri = 'http://localhost:5000/v2.0'
      expected_auth_uri = 'http://localhost:5000/v3'
      expect(
        subject.auth_uri_transform(auth_uri, auth_version)
      ).to eq(expected_auth_uri)
    end
  end
end
