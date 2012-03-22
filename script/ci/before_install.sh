#!/bin/bash

# Workaround dependency issues
if ([ "$DB" == "postgres" -a "$TRAVIS_RUBY_VERSION" == "ree" ]); then
  echo "Rebuild Gemfile.lock to get rid of diaspora-clients 1.9 dependencies"
  bundle update diaspora-client
fi


# Ensure known RubyGems version
if [ "$(gem --version)" != "1.8.17" ]; then
  echo "RubyGems version is $(gem --version). Changing..."
  rvm rubygems 1.8.17
  echo "Changed RubyGems version to $(gem --version)."
fi
