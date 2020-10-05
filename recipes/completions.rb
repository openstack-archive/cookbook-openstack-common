#
# Cookbook:: openstack-common
# Recipe:: completions
#
# Copyright:: 2019, x-ion GmbH
# Copyright:: 2020, Oregon State University
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
package 'bash-completion'

directory '/etc/bash_completion.d/' do
  mode '755'
end

execute 'create OSC bash completions' do
  command "openstack complete > #{node['openstack']['common']['bash_complete']}"
  creates node['openstack']['common']['bash_complete']
end
