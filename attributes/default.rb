#
# Cookbook Name:: openstack-common
# Attributes:: default
#
# Copyright 2012, Jay Pipes
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ======================== OpenStack Endpoints ================================
#
# OpenStack recipes often need information about the various service
# endpoints in the deployment. For instance, the cookbook that deploys
# the Nova API service will need to set the glance_api_servers configuration
# option in the nova.conf, and the cookbook setting up the Glance image
# service might need information on the Swift proxy endpoint, etc. Having
# all of this related OpenStack endpoint information in a single set of
# common attributes in the openstack-common cookbook attributes means that
# instead of doing funky role-based lookups, a deployment zone's OpenStack
# endpoint information can simply be accessed by having the
# openstack-common::default recipe added to some base role definition file
# that all OpenStack nodes add to their run list.
#
# node['openstack']['endpoints'] is a hash of hashes, where each value hash
# contains one of more of the following keys:
#
#  - scheme
#  - uri
#  - host
#  - port
#  - path
#
# If the uri key is set, its value is used as the full URI for the endpoint.
# If the uri key is not set, the endpoint's full URI is constructed from the
# component parts. This allows setups that use some standardized DNS names for
# OpenStack service endpoints in a deployment zone as well as setups that
# instead assign IP addresses (for an actual node or a load balanced virtual
# IP) in a network to a particular OpenStack service endpoint.

# ******************** OpenStack Identity Endpoints ***************************

# The OpenStack Identity (Keystone) API endpoint. This is commonly called
# the Keystone Service endpoint...
default['openstack']['endpoints']['identity-api']['host'] = "127.0.0.1"
default['openstack']['endpoints']['identity-api']['scheme'] = "https"
default['openstack']['endpoints']['identity-api']['port'] = 35357
default['openstack']['endpoints']['identity-api']['path'] = "/v2.0"

# The OpenStack Identity (Keystone) Admin API endpoint
default['openstack']['endpoints']['identity-admin']['host'] = "127.0.0.1"
default['openstack']['endpoints']['identity-admin']['scheme'] = "https"
default['openstack']['endpoints']['identity-admin']['port'] = 5000
default['openstack']['endpoints']['identity-admin']['path'] = "/v2.0"

# ****************** OpenStack Compute Endpoints ******************************

# The OpenStack Compute (Nova) Native API endpoint
default['openstack']['endpoints']['compute-api']['host'] = "127.0.0.1"
default['openstack']['endpoints']['compute-api']['scheme'] = "https"
default['openstack']['endpoints']['compute-api']['port'] = 8774
default['openstack']['endpoints']['compute-api']['path'] = "/v2/%(tenant_id)s"

# The OpenStack Compute (Nova) EC2 API endpoint
default['openstack']['endpoints']['compute-ec2-api']['host'] = "127.0.0.1"
default['openstack']['endpoints']['compute-ec2-api']['scheme'] = "https"
default['openstack']['endpoints']['compute-ec2-api']['port'] = 8773
default['openstack']['endpoints']['compute-ec2-api']['path'] = "/services/Cloud"

# The OpenStack Compute (Nova) EC2 Admin API endpoint
default['openstack']['endpoints']['compute-ec2-admin']['host'] = "127.0.0.1"
default['openstack']['endpoints']['compute-ec2-admin']['scheme'] = "https"
default['openstack']['endpoints']['compute-ec2-admin']['port'] = 8773
default['openstack']['endpoints']['compute-ec2-admin']['path'] = "/services/Admin"

# The OpenStack Compute (Nova) XVPvnc endpoint
default['openstack']['endpoints']['compute-xvpvnc']['host'] = "127.0.0.1"
default['openstack']['endpoints']['compute-xvpvnc']['scheme'] = "https"
default['openstack']['endpoints']['compute-xvpvnc']['port'] = 6081
default['openstack']['endpoints']['compute-xvpvnc']['path'] = "/console"

# The OpenStack Compute (Nova) novnc endpoint
default['openstack']['endpoints']['compute-novnc']['host'] = "127.0.0.1"
default['openstack']['endpoints']['compute-novnc']['scheme'] = "https"
default['openstack']['endpoints']['compute-novnc']['port'] = 6080
default['openstack']['endpoints']['compute-novnc']['path'] = "/vnc_auto.html"

# The OpenStack Compute (Nova) novnc server endpoint
# TODO(jaypipes) Is this necessary? It's the same as the novnc endpoint...
default['openstack']['endpoints']['compute-novnc-server']['host'] = "127.0.0.1"
default['openstack']['endpoints']['compute-novnc-server']['scheme'] = "https"
default['openstack']['endpoints']['compute-novnc-server']['port'] = 6080
default['openstack']['endpoints']['compute-novnc-server']['path'] = "/vnc_auto.html"

# The OpenStack Compute (Nova) Volume endpoint
# Note that this endpoint is NOT a Cinder endpoint. This is the
# older nova-volume service.
default['openstack']['endpoints']['compute-volume']['host'] = "127.0.0.1"
default['openstack']['endpoints']['compute-volume']['scheme'] = "https"
default['openstack']['endpoints']['compute-volume']['port'] = 8776
default['openstack']['endpoints']['compute-volume']['path'] = "/v1/%(tenant_id)s"

# ******************** OpenStack Image Endpoints ******************************

# The OpenStack Image (Glance) API endpoint
default['openstack']['endpoints']['image-api']['host'] = "127.0.0.1"
default['openstack']['endpoints']['image-api']['scheme'] = "https"
default['openstack']['endpoints']['image-api']['port'] = 9292
default['openstack']['endpoints']['image-api']['path'] = "/v2"

# The OpenStack Image (Glance) Registry API endpoint
default['openstack']['endpoints']['image-registry']['host'] = "127.0.0.1"
default['openstack']['endpoints']['image-registry']['scheme'] = "https"
default['openstack']['endpoints']['image-registry']['port'] = 9191
default['openstack']['endpoints']['image-registry']['path'] = "/v2"

# Alternately, if you used some standardized DNS naming scheme, you could
# do something like this, which would override any part-wise specifications above.
#
# default['openstack']['endpoints']['identity-api']['uri']         = "https://identity.example.com:35357/v2.0"
# default['openstack']['endpoints']['identity-admin']['uri']       = "https://identity.example.com:5000/v2.0"
# default['openstack']['endpoints']['compute-api']['uri']          = "https://compute.example.com:8774/v2/%(tenant_id)s"
# default['openstack']['endpoints']['compute-ec2-api']['uri']      = "https://ec2.example.com:8773/services/Cloud"
# default['openstack']['endpoints']['compute-ec2-admin']['uri']    = "https://ec2.example.com:8773/services/Admin"
# default['openstack']['endpoints']['compute-xvpvnc']['uri']       = "https://xvpvnc.example.com:6081/console"
# default['openstack']['endpoints']['compute-novnc']['uri']        = "https://novnc.example.com:6080/vnc_auto.html"
# default['openstack']['endpoints']['compute-volume']['uri']       = "https://volume.example.com:8776/"v1/%(tenant_id)s"
# default['openstack']['endpoints']['image-api']['uri']            = "https://image.example.com:9292/v2"
# default['openstack']['endpoints']['image-registry']['uri']       = "https://image.example.com:9191/v2"
