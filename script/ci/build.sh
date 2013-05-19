#!/bin/sh


# Create a database.yml for the right database
echo "Setting up database.yml for $DB"
cp config/database.yml.example config/database.yml
if [ "$DB" = "postgres" ]; then
  sed -i 's/*common/*postgres_travis/' config/database.yml
fi

command="bundle exec rake --trace ci:travis:${BUILD_TYPE}"

exec xvfb-run --auto-servernum --server-num=1 --server-args="-screen 0 1280x1024x8" $command
