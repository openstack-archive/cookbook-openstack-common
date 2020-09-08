OpenStack Chef Cookbook - common
================================

.. image:: https://governance.openstack.org/badges/cookbook-openstack-common.svg
    :target: https://governance.openstack.org/reference/tags/index.html

.. Change things from this point on

Description
===========

This cookbook provides common setup recipes, helper methods and
attributes that describe an OpenStack deployment as part of the
OpenStack reference deployment Chef for OpenStack.

Please relate to the official OpenStack Configuration and Installation
Guides for a more detailed documentation on operating and administration
of an OpenStack cluster:

https://docs.openstack.org/latest/configuration/
https://docs.openstack.org/latest/install/

Requirements
============

- Chef 15 or higher
- Chef Workstation 20.8.111 for testing (also includes berkshelf for
  cookbook dependency resolution)

Platform
========

-  ubuntu
-  redhat
-  centos

Cookbooks
=========

The following cookbooks are dependencies:

- 'etcd', '~> 6.0'
- 'mariadb', '~> 3.1'
- 'memcached', '~> 6.0'
- 'selinux'
- 'yum-epel'

Attributes
==========

Please see the extensive inline documentation in ``attributes/*.rb`` for
descriptions of all the settable attributes for this cookbook.

Note that all attributes are in the ``default["openstack"]`` "namespace"

Attributes to generate OpenStack service configuration files
------------------------------------------------------------

Since the mitaka release, we moved to a completely new way to generate
all OpenStack service configuration files. The base template is the
``openstack-service.conf.erb`` included in the templates of this
cookbook.  In each of the service cookbook (e.g. openstack-network,
openstack-identity or openstack-compute), the service configuration file
(e.g neutron.conf, keystone.conf or nova.conf) gets generated directly
from attributes set inside the cookbook. To merge all the configuration
options (including the secrets) properly, before handing them over as
``@service_config`` to the mentioned template above, we use the methods
defined in ``libraries/config_helpers``.

For examples how to use these attributes, please refer to the attribute
files included in the service cookbooks (e.g.
``attributes/neutron_conf.rb`` in openstack-network or
``attributes/keystone_conf.rb`` in openstack-identity). The basic
structure of all these attributes always follows this model:

.. code-block:: ruby

    # usual config option that should eventually be saved to the node object
    default['openstack'][service]['conf'][section][key][value]
    # configuration options like passwords that should not be saved in the node
    # object
    default['openstack'][service]['conf_secrets'][section][key][value]

Recipes
=======

openstack-common::client
------------------------

-  Install the common python openstack client package

openstack-common::completions
-----------------------------

-  Install bash completions for openstack client

openstack-common::default
-------------------------

-  Installs/Configures common recipes

openstack-common::etcd
----------------------

-  Installs and starts etcd

openstack-common::logging
-------------------------

-  Installs/Configures common logging

openstack-common::sysctl
------------------------

-  Iterates over the contents of the ``node['openstack']['sysctl']``
   hash and executes the ``sysctl`` resource.

Data Bags
=========

This cookbook contains Libraries to work with passwords and secrets in
databags. Databags can be unencrypted (for dev) or encrypted (for prod).
In addition to traditionally encrypted data bags they can also be
created as chef-vault items. To read more about chef-vault and how to
use it, go to https://docs.chef.io/chef_vault.html.

Documentation for Attributes for selecting databag format can be found
in the attributes section of this cookbook.

Documentation for format of these Databags can be found in the
`Openstack Chef
Repo <https://opendev.org/openstack/openstack-chef#data-bags>`__
repository.

Resources
=========

This cookbook provides the ``openstack_database`` custom resource.  When
this cookbook is included as dependency, this custom resource can be
used to create databases needed by the OpenStack services.

.. code-block:: ruby

    depends 'openstack-common'

.. code-block:: ruby

    openstack_database 'compute' do
      user 'nova'
      pass 'supersecret'
    end

An example of the usage can be seen here
https://opendev.org/openstack/cookbook-openstack-ops-database/src/branch/master/recipes/openstack-db.rb
.

Libraries
=========

This cookbook exposes a set of default library routines:

-  ``cli`` -- Used to call openstack CLIs
-  ``endpoint`` -- Used to return a ``::URI`` object representing the
   named OpenStack endpoint
-  ``internal_endpoint`` -- Used to return a ``::URI`` object
   representing the named OpenStack internal endpoint if one was
   specified. Otherwise, it will return the same value as ``endpoint``.
-  ``public_endpoint`` -- Used to return a ``::URI`` object representing
   the named OpenStack public endpoint if one was specified. Otherwise,
   it will return the same value as ``endpoint``.
-  ``endpoints`` -- Useful for operating on all OpenStack endpoints
-  ``db`` -- Returns a Hash of information about a named OpenStack
   database
-  ``db_uri`` -- Returns the SQLAlchemy RFC-1738 DB URI (see:
   http://rfc.net/rfc1738.html) for a named OpenStack database
-  ``secret`` -- Returns the value of an encrypted data bag for a named
   OpenStack secret key and key-section
-  ``get_password`` -- Ease-of-use helper that returns the decrypted
   password for a named database, service or keystone user.
-  ``matchers`` -- A custom matcher(``render_config_file``) for testing
   ini format file section content by ``with_section_content``.

Examples
========

The following are code examples showing the above library routines in
action. Remember when using the library routines exposed by this library
to include the Openstack routines in your recipe's ``::Chef::Recipe``
namespace, like so:

.. code-block:: ruby

    class ::Chef::Recipe
      include ::Openstack
    end

Example of using the ``endpoint`` routine:

.. code-block:: ruby

    nova_api_ep = endpoint "compute-api"
    ::Chef::Log.info("Using Openstack Compute API endpoint at #{nova_api_ep.to_s}")

    # Note that endpoint URIs may contain variable interpolation markers such
    # as `%(tenant_id)s`, so you may need to decode them. Do so like this:

    require "uri"

    puts ::URI.decode nova_api_ap.to_s

Example of using the ``get_password`` and ``db_uri`` routine:

.. code-block:: ruby

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

URI Operations
--------------

Use the ``Openstack::uri_from_hash`` routine to helpfully return a
``::URI::Generic`` object for a hash that contains any of the following
keys:

-  ``host``
-  ``uri``
-  ``port``
-  ``path``
-  ``scheme``

If the ``uri`` key is in the hash, that will be used as the URI,
otherwise the URI will be constructed from the various parts of the hash
corresponding to the keys above.

.. code-block:: ruby

    # Suppose node hash contains the following subhash in the :identity_service key:
    # {
    #   :host => 'identity.example.com',
    #   :port => 5000,
    #   :scheme => 'https'
    # }
    uri = ::Openstack::uri_from_hash(node[:identity_service])
    # uri.to_s would == "https://identity.example.com:5000"

The routine will return nil if neither a ``uri`` or ``host`` key exists
in the supplied hash.

Using the library without prefixing with ::Openstack
----------------------------------------------------

Don't like prefixing calls to the library's routines with
``::Openstack``? Do this:

.. code-block:: ruby

    class ::Chef::Recipe
      include ::Openstack
    end

in your recipe.

License and Author
==================

+-----------------+-------------------------------------------------+
| **Author**      | Jay Pipes (jaypipes@att.com)                    |
+-----------------+-------------------------------------------------+
| **Author**      | John Dewey (jdewey@att.com)                     |
+-----------------+-------------------------------------------------+
| **Author**      | Matt Ray (matt@opscode.com)                     |
+-----------------+-------------------------------------------------+
| **Author**      | Craig Tracey (craigtracey@gmail.com)            |
+-----------------+-------------------------------------------------+
| **Author**      | Sean Gallagher (sean.gallagher@att.com)         |
+-----------------+-------------------------------------------------+
| **Author**      | Ionut Artarisi (iartarisi@suse.cz)              |
+-----------------+-------------------------------------------------+
| **Author**      | Chen Zhiwei (zhiwchen@cn.ibm.com)               |
+-----------------+-------------------------------------------------+
| **Author**      | Brett Campbell (brett.campbell@rackspace.com)   |
+-----------------+-------------------------------------------------+
| **Author**      | Mark Vanderwiel (vanderwl@us.ibm.com)           |
+-----------------+-------------------------------------------------+
| **Author**      | Jan Klare (j.klare@cloudbau.de)                 |
+-----------------+-------------------------------------------------+
| **Author**      | Christoph Albers (c.albers@x-ion.de)            |
+-----------------+-------------------------------------------------+
| **Author**      | Jens Harbott (j.harbott@x-ion.de)               |
+-----------------+-------------------------------------------------+
| **Author**      | Lance Albertson (lance@osuosl.org)              |
+-----------------+-------------------------------------------------+

+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2012-2013, AT&T Services, Inc.     |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2013, Opscode, Inc.                |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2013, Craig Tracey                 |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2013-2014, SUSE Linux GmbH         |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2013-2015, IBM, Corp.              |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2013-2014, Rackspace US, Inc.      |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2016-2019, x-ion GmbH              |
+-----------------+--------------------------------------------------+
| **Copyright**   | Copyright (c) 2016-2020, Oregon State University |
+-----------------+--------------------------------------------------+

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

::

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
