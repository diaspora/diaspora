source 'https://rubygems.org'

gem 'rails', '4.1.5'

# Legacy Rails features, remove me!

# caches_page
gem 'actionpack-action_caching'
gem 'actionpack-page_caching'

# Appserver

gem 'unicorn', '4.8.3', :require => false

# API and JSON

gem 'acts_as_api', '0.4.2'
gem 'json',        '1.8.1'

# Authentication

gem 'devise', '3.3.0'
gem 'devise_lastseenable', '0.0.4'

# Captcha

gem 'simple_captcha2', '0.2.1', :require => 'simple_captcha'

# Background processing

gem 'sidekiq', '2.17.7'
gem 'sinatra', '1.3.3'

# Compression

gem 'uglifier', '2.5.0'

# Configuration

gem 'configurate', '0.0.8'

# Cross-origin resource sharing

gem 'rack-cors', '0.2.9', :require => 'rack/cors'

# CSS

gem 'bootstrap-sass', '2.3.2.2'
gem 'compass-rails',  '2.0.0'
gem 'sass-rails',     '4.0.3'

# Database

ENV['DB'] ||= 'mysql'

gem 'mysql2', '0.3.16' if ENV['DB'] == 'all' || ENV['DB'] == 'mysql'
gem 'pg',     '0.17.1' if ENV['DB'] == 'all' || ENV['DB'] == 'postgres'

gem 'activerecord-import', '0.5.0'
gem 'foreigner',           '1.6.1'

# File uploading

gem 'carrierwave', '0.10.0'
gem 'fog',         '1.23.0'
gem 'mini_magick', '3.8.0'
gem 'remotipart',  '1.2.1'

# GUID generation
gem 'uuid', '2.3.7'

# Icons

gem 'entypo-rails', '2.2.2'

# JavaScript

gem 'backbone-on-rails', '1.1.1'
gem 'handlebars_assets', '0.12.0'
gem 'jquery-rails',      '3.0.4'

# Localization

gem 'http_accept_language', '1.0.2'
gem 'i18n-inflector-rails', '1.0.7'
gem 'rails-i18n',           '4.0.2'

# Mail

gem 'markerb',             '1.0.2'
gem 'messagebus_ruby_api', '1.0.3'

# Parsing

gem 'nokogiri',         '1.6.1'
gem 'rails_autolink',   '1.1.5'
gem 'redcarpet',        '3.1.2'
gem 'roxml',            '3.1.6'
gem 'ruby-oembed',      '0.8.10'
gem 'opengraph_parser', '0.2.3'


# Services

gem 'omniauth',          '1.2.1'
gem 'omniauth-facebook', '1.6.0'
gem 'omniauth-tumblr',   '1.1'
gem 'omniauth-twitter',  '1.0.1'
gem 'twitter',           '4.8.1'
gem 'omniauth-wordpress','0.2.1'

# Tags

gem 'acts-as-taggable-on', '3.3.0'

# URIs and HTTP

gem 'addressable',        '2.3.6', :require => 'addressable/uri'
gem 'faraday',            '0.8.9'
gem 'faraday_middleware', '0.9.0'
gem 'typhoeus',           '0.6.9'

# Views

gem 'gon',                     '5.1.2'
gem 'haml',                    '4.0.5'
gem 'mobile-fu',               '1.3.1'
gem 'will_paginate',           '3.0.5'
gem 'rails-timeago',           '2.4.0'

# Workarounds
# https://github.com/rubyzip/rubyzip#important-note
gem 'zip-zip'


# Windows and OSX have an execjs compatible runtime built-in, Linux users should
# install Node.js or use 'therubyracer'.
#
# See https://github.com/sstephenson/execjs#readme for more supported runtimes

# gem 'therubyracer', :platform => :ruby

group :production do # we don't install these on travis to speed up test runs

  # Administration

  gem 'rails_admin', '0.6.3'

  # Analytics

  gem 'rack-google-analytics', '0.14.0', :require => 'rack/google-analytics'
  gem 'rack-piwik',            '0.3.0',  :require => 'rack/piwik'

  # Click-jacking protection

  gem 'rack-protection', '1.2'

  # Process management

  gem 'foreman', '0.62'

  # Redirects

  gem 'rack-rewrite', '1.5.0', :require => false
  gem 'rack-ssl',     '1.4.1', :require => 'rack/ssl'

  # Third party asset hosting

  gem 'asset_sync', '1.1.0', :require => false
end

group :development do
  # Automatic test runs
  gem 'guard-cucumber', '1.4.1'
  gem 'guard-rspec',    '4.3.1'
  gem 'rb-fsevent',     '0.9.4', :require => false
  gem 'rb-inotify',     '0.9.5', :require => false

  # Preloading environment

  gem 'guard-spork', '1.5.1'
  gem 'spork',       '1.0.0rc4'
end

group :test do
  # RSpec (unit tests, some integration tests)

  gem 'fixture_builder',   '0.3.6'
  gem 'fuubar',            '1.3.3'
  gem 'rspec-instafail',   '0.2.5', :require => false
  gem 'test_after_commit', '0.2.5'

  # Cucumber (integration tests)

  gem 'capybara',           '2.4.1'
  gem 'database_cleaner',   '1.3.0'
  gem 'selenium-webdriver', '2.42.0'

  # General helpers

  gem 'factory_girl_rails', '4.4.1'
  gem 'timecop',            '0.7.1'
  gem 'webmock',            '1.18.0', :require => false
end


group :development, :test do
  # RSpec (unit tests, some integration tests)
  gem "rspec-rails",     '2.14.2'

  # Cucumber (integration tests)
  gem 'cucumber-rails',     '1.4.1', :require => false

  # Jasmine (client side application tests (JS))
  gem 'jasmine',              '2.0.2'
  gem 'jasmine-jquery-rails', '2.0.3'
  gem 'sinon-rails',	      '1.9.0'
end
