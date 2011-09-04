# Remove Gemfile.lock and rebundle on Ruby 1.9
ruby -e "system('rm Gemfile.lock') if RUBY_VERSION.include?('1.9')"
ruby -e "system('bundle install --without development production') if RUBY_VERSION.include?('1.9')"

# Change Gemfile if this is a postgresql build
echo $DB
ruby -e "system('cp config/ci/Gemfile.postgresql Gemfile') if ENV['DB'] == 'postgres'"

# Create a database.yml for the right database
cp config/database.yml.example config/database.yml
ruby -e "system('cp config/ci/database.yml.postgresql config/database.yml') if ENV['DB'] == 'postgres'"

# adjust GC settings for REE
export RUBY_HEAP_MIN_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000

# Install firefox and start xvfb in preparation for cucumber & jasmine
sudo aptitude -q2 -y install firefox
sudo cp config/ci/xvfb /etc/init.d/xvfb
sh -e /etc/init.d/xvfb start

# Regenerate css files
sass --update public/stylesheets/sass/:public/stylesheets/

# Set up database
bundle exec rake db:create
bundle exec rake db:schema:load
