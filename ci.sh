#!/bin/bash

echo "*************************************************************************************************" &&
echo "*                                  ruby 1.8.7-p249 build                                        *" &&
echo "*************************************************************************************************" &&
echo "" &&
rm Gemfile.lock &&
source /usr/local/rvm/scripts/rvm &&
rvm use ruby-1.8.7-p249 &&
bundle install &&
bundle exec rake ci &&
echo "" &&
echo "*************************************************************************************************" &&
echo "*                                   ruby 1.9.2-p0 build                                         *" &&
echo "*************************************************************************************************" &&
echo "" &&
rm Gemfile.lock &&
source /usr/local/rvm/scripts/rvm &&
rvm use ruby-1.9.2-p0 &&
bundle install &&
bundle exec rake ci
