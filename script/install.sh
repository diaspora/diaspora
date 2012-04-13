#!/bin/bash

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