#!/bin/sh
# install selenium prerelease
gem install selenium-webdriver --pre
gem list

# Ensure known RubyGems version
envdir="$(readlink -e $(dirname $0))/../env"
. "$envdir/ruby_env"
. "$envdir/ensure_right_rubygems"

