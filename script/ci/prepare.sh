#!/bin/sh

# Create a database.yml for the right database
echo "Setting up database.yml for ${DB}"
cp config/database.yml.example config/database.yml
if [ "${DB}" = "mysql" ]; then
  sed -i 's/*common/*mysql/' config/database.yml
fi

gem install bundler
script/configure_bundler
