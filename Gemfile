source 'https://rubygems.org'

gem 'rails', '3.2.17'

# Appserver

gem 'unicorn', '4.8.0', :require => false

# API and JSON

gem 'acts_as_api', '0.4.2'
gem 'json',        '1.8.1'

# Authentication

gem 'devise', '3.2.2'
gem 'devise_lastseenable', '0.0.4'

# Captcha

gem 'galetahub-simple_captcha', '0.1.5', :require => 'simple_captcha'

# Background processing

gem 'sidekiq', '2.17.2'
gem 'sinatra', '1.3.3'

# Configuration

gem 'configurate', '0.0.8'

# Cross-origin resource sharing

gem 'rack-cors', '0.2.8', :require => 'rack/cors'

# Database

ENV['DB'] ||= 'mysql'

gem 'mysql2', '0.3.14' if ENV['DB'] == 'all' || ENV['DB'] == 'mysql'
gem 'pg',     '0.17.1' if ENV['DB'] == 'all' || ENV['DB'] == 'postgres'

gem 'activerecord-import', '0.3.1'
gem 'foreigner',           '1.6.1'

# File uploading

gem 'carrierwave', '0.9.0'
gem 'fog',         '1.19.0'
gem 'mini_magick', '3.7.0'
gem 'remotipart',  '1.2.1'

# GUID generation
gem 'uuid', '2.3.7'

# Localization

gem 'http_accept_language', '1.0.2'
gem 'i18n-inflector-rails', '1.0.7'
gem 'rails-i18n',           '0.7.4'

# Mail

gem 'markerb',             '1.0.1'
gem 'messagebus_ruby_api', '1.0.3'

# Parsing

gem 'nokogiri',         '1.6.1'
gem 'rails_autolink',   '1.1.5'
gem 'redcarpet',        '3.1.1'
gem 'roxml',            '3.1.6'
gem 'ruby-oembed',      '0.8.9'
gem 'opengraph_parser', '0.2.3'


# Please remove when migrating to Rails 4
gem 'strong_parameters'


# Services

gem 'omniauth',          '1.1.4'
gem 'omniauth-facebook', '1.6.0'
gem 'omniauth-tumblr',   '1.1'
gem 'omniauth-twitter',  '1.0.1'
gem 'twitter',           '4.8.1'
gem 'omniauth-wordpress','0.2.0'

# Tags

gem 'acts-as-taggable-on', '2.4.1'

# URIs and HTTP

gem 'addressable',        '2.3.5', :require => 'addressable/uri'
gem 'faraday',            '0.8.9'
gem 'faraday_middleware', '0.9.0'
gem 'typhoeus',           '0.6.7'

# Views

gem 'gon',                     '4.1.1'
gem 'haml',                    '4.0.5'
gem 'mobile-fu',               '1.2.2'
gem 'will_paginate',           '3.0.5'
gem 'rails-timeago'

# Workarounds
# https://github.com/rubyzip/rubyzip#important-note
gem 'zip-zip'

### GROUPS ####

group :assets do

  # Icons
  gem 'entypo-rails'

  # CSS

  gem 'bootstrap-sass', '2.2.2.0'
  gem 'compass-rails',  '1.0.3'
  gem 'sass-rails',     '3.2.6'

  # Compression

  gem 'uglifier', '2.1.2'

  # JavaScript

  gem 'backbone-on-rails', '1.1.0'
  gem 'handlebars_assets', '0.12.0'
  gem 'jquery-rails',      '3.0.4'

  # Windows and OSX have an execjs compatible runtime built-in, Linux users should
  # install Node.js or use 'therubyracer'.
  #
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes

  # gem 'therubyracer', :platform => :ruby
end

group :production do # we don't install these on travis to speed up test runs

  # Administration

  gem 'rails_admin', '0.4.9'

  # Analytics

  gem 'rack-google-analytics', '0.14.0', :require => 'rack/google-analytics'
  gem 'rack-piwik',            '0.2.2',  :require => 'rack/piwik'

  # Click-jacking protection

  gem 'rack-protection', '1.2'

  # Process management

  gem 'foreman', '0.62'

  # Redirects

  gem 'rack-rewrite', '1.5.0', :require => false
  gem 'rack-ssl',     '1.3.3', :require => 'rack/ssl'

  # Third party asset hosting

  gem 'asset_sync', '1.0.0', :require => false
end

group :development do
  # Automatic test runs
  gem 'guard-cucumber', '1.4.1'
  gem 'guard-rspec',    '4.2.4'
  gem 'rb-fsevent',     '0.9.4', :require => false
  gem 'rb-inotify',     '0.9.3', :require => false

  # Preloading environment

  gem 'guard-spork', '1.5.1'
  gem 'spork',       '1.0.0rc4'
end

group :test do
  # RSpec (unit tests, some integration tests)

  gem 'fixture_builder',   '0.3.6'
  gem 'fuubar',            '1.3.2'
  gem 'rspec-instafail',   '0.2.4', :require => false
  gem 'test_after_commit', '0.2.2'

  # Cucumber (integration tests)

  gem 'capybara',           '2.2.1'
  gem 'database_cleaner',   '1.2.0'
  gem 'selenium-webdriver', '2.39.0'

  # General helpers

  gem 'factory_girl_rails', '4.3.0'
  gem 'timecop',            '0.7.1'
  gem 'webmock',            '1.16.1', :require => false
end


group :development, :test do
  # RSpec (unit tests, some integration tests)
  gem "rspec-rails",     '2.14.1'

  # Cucumber (integration tests)
  gem 'cucumber-rails',     '1.4.0', :require => false

  # Jasmine (client side application tests (JS))
  gem 'jasmine', '1.3.2'
  gem 'sinon-rails',	    '1.7.3'
end
