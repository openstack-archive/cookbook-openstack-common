Description
===========

Cookbook containing common setup recipes and attributes that describe
an OpenStack deployment.

Requirements
============

* Chef 0.8+

Cookbooks
---------

The following cookbooks are dependencies:

* apt
* database
* openstack-utils

Attributes
==========

Please see the extensive inline documentation in `attributes/default.rb` for descriptions
of all the settable attributes for this cookbook.

Note that all attributes are in the `default["openstack"]` "namespace"

Libraries
=========

This cookbook exposes a set of default library routines:

* `endpoint` -- Used to return a `::URI` object representing the named OpenStack endpoint
* `endpoints` -- Useful for operating on all OpenStack endpoints
* `db` -- Returns a Hash of information about a named OpenStack database
* `db_uri` -- Returns the SQLAlchemy RFC-1738 DB URI (see: http://rfc.net/rfc1738.html) for a named OpenStack database
* `db_create_with_user` -- Creates a database and database user for a named OpenStack database
* `secret` -- Returns the value of an encrypted data bag for a named OpenStack secret key and key-section
* `db_password` -- Ease-of-use helper that returns the decrypted database password for a named OpenStack database
* `service_password` -- Ease-of-use helper that returns the decrypted service password for named OpenStack service
* `user_password` -- Ease-of-use helper that returns the decrypted password for a Keystone user

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

Example of using the `db_password` and `db_uri` routine:

```ruby
db_pass = db_password "cinder"
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

Testing
=====

This cookbook is using [ChefSpec](https://github.com/acrmp/chefspec) for testing.

    $ cd $repo
    $ bundle
    $ librarian-chef install
    $ ln -s ../ cookbooks/$short_repo_name # doesn't contain "cookbook-"
    $ foodcritic cookbooks/$short_repo_name
    $ bundle exec rspec cookbooks/$short_repo_name

License and Author
==================

Author:: Jay Pipes (<jaypipes@gmail.com>)

Copyright 2012, Jay Pipes

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
