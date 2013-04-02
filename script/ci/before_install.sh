#!/bin/sh

# Travis CI still includes 1.2.x by default
gem install bundler --version '>= 1.3.4'

# Ensure known RubyGems version
envdir="$(readlink -e $(dirname $0))/../env"
. "$envdir/ruby_env"
. "$envdir/ensure_right_rubygems"
