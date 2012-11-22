#!/bin/sh

# Ensure known RubyGems version
envdir="$(readlink -e $(dirname $0))/../env"
. "$envdir/ruby_env"
. "$envdir/ensure_right_rubygems"

if [ "$BUILD_TYPE" = "cucumber" ]; then
  sudo apt-get install -y firefox=16.0.2
fi
