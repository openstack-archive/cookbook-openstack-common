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
# node["openstack"]["endpoints"] is a hash of hashes, where each value hash
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

default["openstack"]["endpoints"] = {}
ep = default["openstack"]["endpoints"]

# ******************** OpenStack Identity Endpoints ***************************

# The OpenStack Identity (Keystone) API endpoint. This is commonly called
# the Keystone Service endpoint...
ep["identity-api"]["host"] = "127.0.0.1"
ep["identity-api"]["scheme"] = "https"
ep["identity-api"]["port"] = 35357
ep["identity-api"]["path"] = "/v2.0"

# The OpenStack Identity (Keystone) Admin API endpoint
ep["identity-admin"]["host"] = "127.0.0.1"
ep["identity-admin"]["scheme"] = "https"
ep["identity-admin"]["port"] = 5000
ep["identity-admin"]["path"] = "/v2.0"

# ****************** OpenStack Compute Endpoints ******************************

# The OpenStack Compute (Nova) Native API endpoint
ep["compute-api"]["host"] = "127.0.0.1"
ep["compute-api"]["scheme"] = "https"
ep["compute-api"]["port"] = 8774
ep["compute-api"]["path"] = "/v2/%(tenant_id)s"

# The OpenStack Compute (Nova) EC2 API endpoint
ep["compute-ec2-api"]["host"] = "127.0.0.1"
ep["compute-ec2-api"]["scheme"] = "https"
ep["compute-ec2-api"]["port"] = 8773
ep["compute-ec2-api"]["path"] = "/services/Cloud"

# The OpenStack Compute (Nova) EC2 Admin API endpoint
ep["compute-ec2-admin"]["host"] = "127.0.0.1"
ep["compute-ec2-admin"]["scheme"] = "https"
ep["compute-ec2-admin"]["port"] = 8773
ep["compute-ec2-admin"]["path"] = "/services/Admin"

# The OpenStack Compute (Nova) XVPvnc endpoint
ep["compute-xvpvnc"]["host"] = "127.0.0.1"
ep["compute-xvpvnc"]["scheme"] = "https"
ep["compute-xvpvnc"]["port"] = 6081
ep["compute-xvpvnc"]["path"] = "/console"

# The OpenStack Compute (Nova) novnc endpoint
ep["compute-novnc"]["host"] = "127.0.0.1"
ep["compute-novnc"]["scheme"] = "https"
ep["compute-novnc"]["port"] = 6080
ep["compute-novnc"]["path"] = "/vnc_auto.html"

# The OpenStack Compute (Nova) novnc server endpoint
# TODO(jaypipes) Is this necessary? It's the same as the novnc endpoint...
ep["compute-novnc-server"]["host"] = "127.0.0.1"
ep["compute-novnc-server"]["scheme"] = "https"
ep["compute-novnc-server"]["port"] = 6080
ep["compute-novnc-server"]["path"] = "/vnc_auto.html"

# The OpenStack Compute (Nova) Volume endpoint
# Note that this endpoint is NOT a Cinder endpoint. This is the
# older nova-volume service.
ep["compute-volume"]["host"] = "127.0.0.1"
ep["compute-volume"]["scheme"] = "https"
ep["compute-volume"]["port"] = 8776
ep["compute-volume"]["path"] = "/v1/%(tenant_id)s"

# ******************** OpenStack Image Endpoints ******************************

# The OpenStack Image (Glance) API endpoint
ep["image-api"]["host"] = "127.0.0.1"
ep["image-api"]["scheme"] = "https"
ep["image-api"]["port"] = 9292
ep["image-api"]["path"] = "/v2"

# The OpenStack Image (Glance) Registry API endpoint
ep["image-registry"]["host"] = "127.0.0.1"
ep["image-registry"]["scheme"] = "https"
ep["image-registry"]["port"] = 9191
ep["image-registry"]["path"] = "/v2"

# Alternately, if you used some standardized DNS naming scheme, you could
# do something like this, which would override any part-wise specifications above.
#
# ep["identity-api"]["uri"]         = "https://identity.example.com:35357/v2.0"
# ep["identity-admin"]["uri"]       = "https://identity.example.com:5000/v2.0"
# ep["compute-api"]["uri"]          = "https://compute.example.com:8774/v2/%(tenant_id)s"
# ep["compute-ec2-api"]["uri"]      = "https://ec2.example.com:8773/services/Cloud"
# ep["compute-ec2-admin"]["uri"]    = "https://ec2.example.com:8773/services/Admin"
# ep["compute-xvpvnc"]["uri"]       = "https://xvpvnc.example.com:6081/console"
# ep["compute-novnc"]["uri"]        = "https://novnc.example.com:6080/vnc_auto.html"
# ep["compute-volume"]["uri"]       = "https://volume.example.com:8776/"v1/%(tenant_id)s"
# ep["image-api"]["uri"]            = "https://image.example.com:9292/v2"
# ep["image-registry"]["uri"]       = "https://image.example.com:9191/v2"
