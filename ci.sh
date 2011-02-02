#!/bin/bash

echo "*************************************************************************************************" &&
echo "*                                  ruby 1.8.7 REE build                                         *" &&
echo "*************************************************************************************************" &&
echo "" &&
rm -f Gemfile.lock &&
source /usr/local/rvm/scripts/rvm &&
rvm use ree@diaspora --create &&
rm -rf /usr/local/rvm/gems/ree-1.8.7-2010.02@diaspora/cache &&
rm -rf /usr/local/rvm/gems/ree-1.8.7-2010.02@global/cache &&
rm -rf /usr/local/rvm/gems/ree-1.8.7-2010.02/cache &&
bundle install &&
bundle exec rake cruise
