#!/usr/bin/env bash

# A script to run tests locally before committing.

set -e

COOKBOOK=$(awk '/^name/ {print $NF}' metadata.rb |tr -d \"\')

bundle install
bundle exec berks install --path .cookbooks
bundle exec foodcritic -f any -t ~FC003 -t ~FC023 .cookbooks/${COOKBOOK}
bundle exec rspec .cookbooks/${COOKBOOK}
