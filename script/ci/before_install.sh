#!/bin/bash

# Ensure known RubyGems version
if [ "$(gem --version)" != "1.8.15" ]; then
  echo "RubyGems version is $(gem --version). Changing..."
  rvm rubygems 1.8.15
  echo "Changed RubyGems version to $(gem --version)."
fi

# Get latest bundler
gem install bundler --pre
