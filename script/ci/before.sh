#!/bin/bash

# Install firefox & Xvfb, in preparation for cucumber & jasmine

#echo "Installing Firefox and Xvfb"
#sudo aptitude --quiet=2 --without-recommends --assume-yes install firefox xvfb
#sudo cp script/ci/xvfb /etc/init.d/xvfb
echo "Start Xvfb"
sh -e /etc/init.d/xvfb start

# Regenerate css files
#echo "Regenerating CSS files"
#bundle exec sass -q --update public/stylesheets/sass/:public/stylesheets/

# setup swapfile
#echo "creating a swapfile"
#sudo dd if=/dev/zero of=swapfile bs=1M count=96
#sudo mkswap swapfile
#sudo swapon swapfile
#sudo sysctl vm.swappiness=100

# Create a database.yml for the right database
echo "Setting up database.yml for $DB"
cp config/database.yml.example config/database.yml
if [ "$DB" = "postgres" ]; then
  sed -i 's/*mysql/*postgres/' config/database.yml
fi

# Set up database
echo "Creating databases for $DB and loading schema"
bundle exec rake db:create --trace
bundle exec rake db:schema:load --trace
