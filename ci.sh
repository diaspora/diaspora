#!/bin/bash

echo "*************************************************************************************************" &&
echo "*                                  ruby 1.8.7 REE build                                         *" &&
echo "*************************************************************************************************" &&
echo "" &&
source /usr/local/rvm/scripts/rvm &&
rvm use ree@diaspora --create &&
bundle install &&
bundle exec rake cruise
