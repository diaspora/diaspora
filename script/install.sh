#!/bin/bash
#MAKE ME BETTER
# see https://github.com/jamiew/git-friendly for more ideas

#maybe this should be two files
#one which includes cloning diaspora/diaspora, and one that assumes you already cloned it yourself
# maybe one script just calls another?


#other ideas what we could do

#1. check that you have ruby installed, if not, point to wiki page and exit
#2. check to see if we need sudo (generally, if it is a system ruby you need sudo, which you can check
 # if which ruby is /usr/bin/ruby, or does not have rvm in the path)
#3 check if you have bundle installed and install it, and install with/without sudo if you need it

#check if you have mysql and/or postgres installed, point to wiki page if neither is found.
#(maybe even switch database.yml if this is the case?)

#make it work if you have just cloned diapsora and want a quick setup, or
#support magic install, like this http://docs.meteor.com/#quickstart


# echo "downloading diaspora"
#git clone git@github.com:diaspora/diaspora.git

# echo 'moving into diaspora'
#cd diaspora

echo "initializing Diaspora*"
echo "copying database.yml.example to database.yml"
cp config/database.yml.example config/database.yml

echo "copying application.yml.example to application.yml"
cp config/application.yml.example config/application.yml

echo "bundling..."
bundle install

echo "creating and migrating default database in config/database.yml. please wait..."
rake db:create db:migrate --trace

echo "It worked!  now start your server in development mode with 'rails s'"
exit 0