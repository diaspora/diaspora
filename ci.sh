#!/bin/bash

echo "*************************************************************************************************" &&
echo "*                                  ruby 1.8.7 REE build                                         *" &&
echo "*************************************************************************************************" &&
echo "" &&
rm -f Gemfile.lock &&
source /usr/local/rvm/scripts/rvm &&
rvm use ree@diaspora --create &&
export RUBY_HEAP_MIN_SLOTS=1000000 &&
export RUBY_HEAP_SLOTS_INCREMENT=1000000 &&
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1 &&
export RUBY_GC_MALLOC_LIMIT=1000000000 &&
export RUBY_HEAP_FREE_MIN=500000 &&
rm -rf /usr/local/rvm/gems/ree-1.8.7-2010.02@diaspora/cache &&
rm -rf /usr/local/rvm/gems/ree-1.8.7-2010.02@global/cache &&
rm -rf /usr/local/rvm/gems/ree-1.8.7-2010.02/cache &&
bundle install &&
bundle exec rake cruise
