source 'http://rubygems.org'

gem 'bundler', '> 1.1.0'

gem 'rails', '3.2.8'

gem 'foreman', '0.59'

gem 'unicorn', '4.3.1', :require => false

gem 'rails_autolink', '1.0.9'

# cross-origin resource sharing

gem 'rack-cors', '0.2.7', :require => 'rack/cors'

# authentication

gem 'devise', '2.1.2'

gem 'remotipart', '1.0.2'

gem 'omniauth', '1.1.1'
gem 'omniauth-facebook', '1.4.1'
gem 'omniauth-tumblr', '1.1'
gem 'omniauth-twitter', '0.0.13'

gem 'twitter', '4.1.1'

# mail

gem 'markerb', :git => 'https://github.com/plataformatec/markerb.git'
gem 'messagebus_ruby_api', '1.0.3'

group :production do # we don't install these on travis to speed up test runs
  gem 'rails_admin', '0.1.1'
  gem 'fastercsv', '1.5.5', :require => false
  gem 'rack-ssl', '1.3.2', :require => 'rack/ssl'
  gem 'rack-rewrite', '1.2.1', :require => false

  # analytics
  gem 'rack-google-analytics', '0.11.0', :require => 'rack/google-analytics'
  gem 'rack-piwik', '0.1.3', :require => 'rack/piwik', :require => false
  
end


# database

gem "activerecord-import", "0.2.11"
gem 'foreigner', '1.2.1'
gem 'mysql2', '0.3.11' if ENV['DB'].nil? || ENV['DB'] == 'all' || ENV['DB'] == 'mysql'
gem 'pg', '0.14.1' if ENV['DB'] == 'all' || ENV['DB'] == 'postgres'
gem 'sqlite3' if ENV['DB'] == 'all' || ENV['DB'] == 'sqlite'

# file uploading

gem 'carrierwave', '0.6.2'
gem 'fog', '1.6.0'
gem 'mini_magick', '3.4'

# JSON and API

gem 'json', '1.7.5'
gem 'acts_as_api', '0.4.1 '

# localization

gem 'i18n-inflector-rails', '~> 1.0'
gem 'rails-i18n', :git => "https://github.com/svenfuchs/rails-i18n.git"

# parsing

gem 'nokogiri', '1.5.5'
gem 'redcarpet', "2.1.1"
gem 'roxml', :git => 'https://github.com/Empact/roxml.git', :ref => '7ea9a9ffd2338aaef5b0'
gem 'ruby-oembed', '0.8.7'

# queue

gem 'resque', '1.22.0'
gem 'resque-timeout', '1.0.0'

# tags

gem 'acts-as-taggable-on', '2.3.3'

# URIs and HTTP

gem 'addressable', '2.3.2', :require => 'addressable/uri'
gem 'http_accept_language', '1.0.2'
gem 'typhoeus', '0.3.3'

# views

gem 'haml', '3.1.7'
gem 'mobile-fu', '1.1.0'

gem 'will_paginate', '3.0.3'
gem 'client_side_validations', '3.1.4'
gem 'gon', '4.0.0'

# assets

group :assets do
  gem 'bootstrap-sass', '2.1.0.0'
  gem 'sass-rails', '3.2.5'

  # Windows and OSX have an execjs compatible runtime built-in, Linux users should
  # install Node.js or use 'therubyracer'.
  #
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes

  # gem 'therubyracer', :platform => :ruby

  gem 'handlebars_assets', '0.6.5'
  gem 'uglifier', '1.3.0'

  gem "asset_sync", '0.5.0', :require => false
end

gem 'jquery-rails', '2.1.3'

# web

gem 'faraday', '0.8.4'
gem 'faraday_middleware', '0.8.8'


gem 'jasmine', '1.2.1'

### GROUPS ####

group :test do


  gem 'capybara', '1.1.2'
  gem 'cucumber-rails', '1.3.0', :require => false
  gem 'database_cleaner', '0.8'

  gem 'timecop', '0.5.3'
  gem 'factory_girl_rails', '4.1.0'
  gem 'fixture_builder', '0.3.4'
  gem 'fuubar', '1.0.0'
  gem 'rspec-instafail', '0.2.4', :require => false
  gem 'selenium-webdriver', '2.25.0'

  gem 'webmock', '1.8.10', :require => false

  gem 'spork', '1.0.0rc3'
  gem 'guard-rspec', '0.7.3'
  gem 'guard-spork', '0.8.0'
  gem 'guard-cucumber', '1.0.0'

end

group :test, :development do
  gem 'debugger', '1.2.0'
  gem "rspec-rails", "2.11.0" 
end

group :development do
  gem 'capistrano', '2.12.0', :require => false
  gem 'capistrano_colors', '0.5.5', :require => false
  gem 'capistrano-ext', '1.2.1', :require => false
end
