# encoding: UTF-8

#
# Cookbook Name:: openstack-common
# library:: uri
#
# Copyright 2012-2013, AT&T Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

# URI methods
module ::Openstack
  # Returns a uri::URI from a hash. If the hash has a 'uri' key, the value
  # of that is returned. If not, then the routine attempts to construct
  # the URI from other parts of the hash.  The values of the 'port' and 'path'
  # keys are used directly from the hash.  For the host, if the
  # 'bind_interface' key is non-nil then it will use the first IP address on
  # the specified interface, otherwise it will use the value of the 'host' key
  # from the hash.
  #
  # Returns nil if the 'uri' key does not exist in the supplied hash and if
  # the determined host is nil (both the values of the 'bind_interface' and
  # 'host' keys are nil).
  def uri_from_hash(hash)
    if hash['uri']
      ::URI.parse ::URI.encode(hash['uri'])
    else
      host = address hash
      return nil unless host

      scheme = hash['scheme'] ? hash['scheme'] : 'http'
      port = hash['port']  # Returns nil if missing, which is fine.
      path = hash['path']  # Returns nil if missing, which is fine.
      ::URI::Generic.new scheme, nil, host, port, nil, path, nil, nil, nil
    end
  end

  # Helper for joining URI paths. The standard URI::join method is not
  # intended for joining URI relative path segments. This function merely
  # helps to accurately join supplied paths.
  def uri_join_paths(*paths)
    return nil if paths.length == 0
    leadingslash = paths[0][0] == '/' ? '/' : ''
    trailingslash = paths[-1][-1] == '/' ? '/' : ''
    paths.map! { |path| path.sub(%r{^\/+}, '').sub(%r{\/+$}, '') }
    leadingslash + paths.join('/') + trailingslash
  end

  def auth_uri_transform(auth_uri, auth_version)
    case auth_version
    when 'v2.0'
      auth_uri
    when 'v3.0'
      # The auth_uri should contain /v2.0 in most cases, but if the
      # auth_version is v3.0, we set it to v3. This is only necessary
      # for environments that need to support V3 non-default-domain
      # tokens, which is really the only reason to set version to
      # something other than v2.0 (the default)
      auth_uri.gsub('/v2.0', '/v3')
    end
  end

  # Helper for creating identity_uri value for the auth_token section
  # of component config files.
  # The definition of identity is: the unversioned root
  # admin identity endpoint e.g. https://localhost:35357/
  # This method will make sure the path is removed from the uri.
  def identity_uri_transform(identity_uri)
    uri = ::URI.parse ::URI.encode(identity_uri.to_s)
    uri.path = '/'
    uri.to_s
  end
end
