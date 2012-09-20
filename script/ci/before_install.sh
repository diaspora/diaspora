#!/bin/bash

# Ensure known RubyGems version
envdir="$(readlink -e $(dirname $0))/../env"
source "$envdir/ruby_env"
source "$envdir/ensure_right_rubygems"
