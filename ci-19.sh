#!/bin/bash

echo "*********************************************************************************" &&
echo "*                            ruby 1.9.2-p0 build                                *" &&
echo "*     Runs tests we can't run on travis because their VMs are a bit puny.       *" &&
echo "*********************************************************************************" &&
echo "" &&
rm -f Gemfile.lock &&
source /usr/local/rvm/scripts/rvm &&
rvm use ruby-1.9.2-p0@diaspora --create &&
bundle install &&
CI=true bundle exec rake ci:hard_things
