#
# Cookbook Name:: openstack-common
# library:: roles
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

module ::Openstack
  # Returns the hash for a node that has the supplied
  # role in its run list. An optional section parameter
  # may be passed which limits the returned hash to just
  # the section of the node hash matching the supplied key.
  #
  # If no node is found having the supplied role, nil is
  # returned.
  def config_by_role role, section=nil
    if node.run_list.roles.include?(role)
      # If we're on a node that contains the searched-for role, just
      # return the node hash or subsection
      section.nil? ? node : node[section]
    else
      # Otherwise, let's look up the role based on the Chef environment
      # of the current node and the searched-for role
      result = search_for role

      if result.empty?
        log("Searched for role #{role} by found no nodes with that role in run list.") { level :debug }
        nil
      else
        section.nil? ? result : result[section]
      end
    end
  end
end
