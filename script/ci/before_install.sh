#!/bin/bash

# Ensure known RubyGems version
if [ "$(gem --version)" != "1.8.17" ]; then
  echo "RubyGems version is $(gem --version). Changing..."
  rvm rubygems 1.8.17
  echo "Changed RubyGems version to $(gem --version)."
fi
