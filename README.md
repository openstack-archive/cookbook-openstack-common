Description
===========

This cookbook provides common setup recipes, helper methods and attributes that describe an OpenStack deployment as part of the OpenStack reference deployment Chef for OpenStack.

Requirements
============

* Chef 0.10.0 or higher required (for Chef environment use).

Cookbooks
---------

The following cookbooks are dependencies:

* apt
* database
* yum
* yum-epel

Attributes
==========

Please see the extensive inline documentation in `attributes/*.rb` for descriptions
of all the settable attributes for this cookbook.

Note that all attributes are in the `default["openstack"]` "namespace"

* `openstack['api']['auth']['version']` - Select v2.0 or v3.0. Default v2.0. The default auth API version used by other components to interact with identity service.

default
-------

Support multiple network types. Default network type is "nova" with the other option supported being "neutron".
The attribute is in the `default["openstack"]["compute"]["network"]["service_type"]`.

Recipes
=======

client
----

Install the common python openstack client package

default
----

Installs/Configures common recipes

```json
"run_list": [
    "recipe[openstack-common]"
]
```

logging
----

Installs/Configures common logging

```json
"run_list": [
    "recipe[openstack-common::logging]"
]
```

set_endpoints_by_interface
----

Iterates over the contents of the `node['openstack']['endpoints']` hash and
finds any occurrence of `bind_interface` to set the IP address
(`node['openstack']['endpoints']['identity']['bind_interface'] = 'eth0'` for
example, overriding `node['openstack']['endpoints']['identity']['host']`). If
`bind_interface` isn't set, the value of `host` is not modified.

```json
"run_list": [
    "recipe[openstack-common::set_endpoints_by_interface]"
]
```

openrc
----

Creates an /root/openrc file. This requires the identity attributes for
admin_user and admin_tenant_name, or for the identity_service_chef_role
to be used on the identity server node.


sysctl
----

Iterates over the contents of the `node['openstack']['sysctl']` hash and writes
the entries to `/etc/sysctl.d/60-openstack.conf`.

```json
"run_list": [
    "recipe[openstack-common::sysctl]"
]
```

Data Bags
=========

This cookbook containes Libraries to work with passwords and secrets in databags.   Databags can be unencrypted ( for dev ) or encrypted ( for prod ). In addition to traditionally encrypted data bags they can also be created as chef-vault items. To read more about chef-vault and how to use it, go to https://docs.getchef.com/chef_vault.html.

Documentation for Attributes for selecting databag format can be found in the attributes section of this cookbook.

Documentation for format of these Databags can be found in the [Openstack Chef Repo](https://github.com/openstack/openstack-chef-repo#databags) repository.

LWRPs
=====

This cookbook provides the openstack_common_database LWRP, which replaces the old database library function 'db_create_with_user'.
When this coobook is included as dependency, this LWRP can be used to create databases needed by the openstack services.

```ruby
depends 'openstack-common'
```

```ruby
openstack_common_database 'compute' do
  service 'compute' # name_attribute
  user 'nova'
  pass 'supersecret'
end
```

An example of the usage can be seen here https://github.com/stackforge/cookbook-openstack-ops-database/blob/master/recipes/openstack-db.rb.

Libraries
=========

This cookbook exposes a set of default library routines:

* `cli` -- Used to call openstack CLIs
* `endpoint` -- Used to return a `::URI` object representing the named OpenStack endpoint
* `admin_endpoint` -- Used to return a `::URI` object representing the named OpenStack admin endpoint if one was specified. Otherwise, it will return the same value as `endpoint`.
* `internal_endpoint` -- Used to return a `::URI` object representing the named OpenStack internal endpoint if one was specified. Otherwise, it will return the same value as `endpoint`.
* `public_endpoint` -- Used to return a `::URI` object representing the named OpenStack public endpoint if one was specified. Otherwise, it will return the same value as `endpoint`.
* `endpoints` -- Useful for operating on all OpenStack endpoints
* `db` -- Returns a Hash of information about a named OpenStack database
* `db_uri` -- Returns the SQLAlchemy RFC-1738 DB URI (see: http://rfc.net/rfc1738.html) for a named OpenStack database
* `secret` -- Returns the value of an encrypted data bag for a named OpenStack secret key and key-section
* `get_password` -- Ease-of-use helper that returns the decrypted password for a named database, service or keystone user.
* `matchers` -- A custom matcher(render_config_file) for testing ini format file section content by with_section_content.

Usage
-----

The following are code examples showing the above library routines in action.
Remember when using the library routines exposed by this library to include
the Openstack routines in your recipe's `::Chef::Recipe` namespace, like so:

```ruby
class ::Chef::Recipe
  include ::Openstack
end
```

Example of using the `endpoint` routine:

```ruby
nova_api_ep = endpoint "compute-api"
::Chef::Log.info("Using Openstack Compute API endpoint at #{nova_api_ep.to_s}")

# Note that endpoint URIs may contain variable interpolation markers such
# as `%(tenant_id)s`, so you may need to decode them. Do so like this:

require "uri"

puts ::URI.decode nova_api_ap.to_s
```

Example of using the `get_password` and `db_uri` routine:

```ruby
db_pass = get_password "db" "cinder"
db_user = node["cinder"]["db"]["user"]
sql_connection = db_uri "volume", db_user, db_pass

template "/etc/cinder/cinder.conf" do
  source "cinder.conf.erb"
  owner  node["cinder"]["user"]
  group  node["cinder"]["group"]
  mode   00644
  variables(
    "sql_connection" => sql_connection
  )
end
```

URI Operations
--------------

Use the `Openstack::uri_from_hash` routine to helpfully return a `::URI::Generic`
object for a hash that contains any of the following keys:

* `host`
* `uri`
* `port`
* `path`
* `scheme`

If the `uri` key is in the hash, that will be used as the URI, otherwise the URI will be
constructed from the various parts of the hash corresponding to the keys above.

```ruby
# Suppose node hash contains the following subhash in the :identity_service key:
# {
#   :host => 'identity.example.com',
#   :port => 5000,
#   :scheme => 'https'
# }
uri = ::Openstack::uri_from_hash(node[:identity_service])
# uri.to_s would == "https://identity.example.com:5000"
```

The routine will return nil if neither a `uri` or `host` key exists in the supplied hash.

Using the library without prefixing with ::Openstack
----------------------------------------------------

Don't like prefixing calls to the library's routines with `::Openstack`? Do this:

```ruby
class ::Chef::Recipe
  include ::Openstack
end
```

in your recipe.

Testing
=====

Please refer to the [TESTING.md](TESTING.md) for instructions for testing the cookbook.

Berkshelf
=====

Berks will resolve version requirements and dependencies on first run and
store these in Berksfile.lock. If new cookbooks become available you can run
`berks update` to update the references in Berksfile.lock. Berksfile.lock will
be included in stable branches to provide a known good set of dependencies.
Berksfile.lock will not be included in development branches to encourage
development against the latest cookbooks.

License and Author
==================

|                      |                                                    |
|:---------------------|:---------------------------------------------------|
| **Author**           |  Jay Pipes (<jaypipes@att.com>)                    |
| **Author**           |  John Dewey (<jdewey@att.com>)                     |
| **Author**           |  Matt Ray (<matt@opscode.com>)                     |
| **Author**           |  Craig Tracey (<craigtracey@gmail.com>)            |
| **Author**           |  Sean Gallagher (<sean.gallagher@att.com>)         |
| **Author**           |  Ionut Artarisi (<iartarisi@suse.cz>)              |
| **Author**           |  Chen Zhiwei (<zhiwchen@cn.ibm.com>)               |
| **Author**           |  Brett Campbell (<brett.campbell@rackspace.com>)   |
| **Author**           |  Mark Vanderwiel (<vanderwl@us.ibm.com>)           |
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2012-2013, AT&T Services, Inc.      |
| **Copyright**        |  Copyright (c) 2013, Opscode, Inc.                 |
| **Copyright**        |  Copyright (c) 2013, Craig Tracey                  |
| **Copyright**        |  Copyright (c) 2013-2014, SUSE Linux GmbH          |
| **Copyright**        |  Copyright (c) 2013-2015, IBM, Corp.               |
| **Copyright**        |  Copyright (c) 2013-2014, Rackspace US, Inc.       |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
