#!/bin/sh

# Ensure known RubyGems version
envdir="$(readlink -e $(dirname $0))/../env"
. "$envdir/ruby_env"
. "$envdir/ensure_right_rubygems"

if [ "$BUILD_TYPE" = "cucumber" ]; then
  sudo aptitude --without-recommends --assume-yes install firefox=16.0.2+build1-0ubuntu0
fi
