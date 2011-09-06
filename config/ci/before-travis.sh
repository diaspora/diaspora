# adjust GC settings for REE
export RUBY_HEAP_MIN_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000


# Start xvfb in preparation for cucumber & jasmine
sh -e /etc/init.d/xvfb start

# Regenerate css files
echo "Regenerate CSS files"
bundle exec sass -q --update public/stylesheets/sass/:public/stylesheets/

# Create a database.yml for the right database
echo "Setting up database.yml for $DB"
cp config/database.yml.example config/database.yml
if [ "$DB" = "postgres" ]; then
  sed -i 's/*mysql/*postgres/' config/database.yml
fi

# Set up database
echo "Creating databases for $DB and loading schema"
bundle exec rake db:create
bundle exec rake db:schema:load
