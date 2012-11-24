#!/bin/sh

# Ensure known RubyGems version
envdir="$(readlink -e $(dirname $0))/../env"
. "$envdir/ruby_env"
. "$envdir/ensure_right_rubygems"

if [ "$BUILD_TYPE" = "cucumber" ]; then
  curl http://security.ubuntu.com/ubuntu/pool/main/f/firefox/firefox_16.0.2+build1-0ubuntu0.11.04.1_i386.deb > firefox.deb
  sudo apt-get install libnotify4
  sudo dpkg -i firefox.deb
fi
