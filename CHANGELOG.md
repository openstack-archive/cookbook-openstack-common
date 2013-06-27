# CHANGELOG for cookbook-openstack-common

This file is used to list changes made in each version of cookbook-openstack-common.

## 0.3.0:
* Added `#rabbit_servers` method, which returns a list of rabbit servers.
* The `#memcached_servers` method no longer accepts an environment.
* Re-factored methods which search to a generic `#search_for`.
* Added `#address_for` method, which returns the IPv4 (default) address of the given
  interface.
* Added global mysql setting of port and db type, for use with wrapper cookbooks.

## 0.2.6:
* Update Chef dependency to Chef 11.

## 0.2.5:
* Moved the default library to database, to better represent its duties.

## 0.2.4:
* Break out #memcached_servers into separate library.

## 0.2.3:
* Sort the results returned by #memcached_servers.

## 0.2.2:
* Provides a mechanism to override memcache_servers search logic through node attributes.

## 0.2.1:
* Adds a prettytable_to_array function for parsing OpenStack CLI output.

## 0.2.0:
* First release of cookbook-openstack-common that aligns with the Grizzly packaging.
* Adds OpenStack Network endpoints.

## 0.1.x:
* Folsom-based packaging.

## 0.0.1:
* Initial release of cookbook-openstack-common.

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
