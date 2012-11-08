Description
===========

Cookbook containing common setup recipes and attributes that describe
an OpenStack deployment.

Requirements
============

* Chef 0.8+

Attributes
==========

Please see the extensive inline documentation in `attributes/default.rb` for descriptions
of all the settable attributes for this cookbook.

Note that all attributes are in the `default["openstack"]` "namespace"

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
