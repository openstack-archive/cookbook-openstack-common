# Cookbook Name:: openstack-common
# library:: wrappers
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

# Wrapper methods
module ::Openstack
  # Wrapper method to allow to easier spec testing
  def recipe_included?(recipe)
    node['recipes'].include?(recipe)
  end

  # Wrapper method to allow to easier spec testing
  def role_included?(role)
    node['roles'].include?(role)
  end
end
