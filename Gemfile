source 'https://rubygems.org'
source 'https://rails-assets.org'

gem 'rails', '4.1.8'

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

gem 'devise', '3.4.1'
gem 'devise_lastseenable', '0.0.4'
gem 'devise-token_authenticatable', '~> 0.3.0'

# Captcha

gem 'simple_captcha2', '0.3.2', :require => 'simple_captcha'

# Background processing

gem 'sidekiq', '3.3.0'
gem 'sinatra', '1.4.5'

# Scheduled processing

gem 'sidetiq', '0.6.3'

# Compression

gem 'uglifier', '2.5.3'

# Configuration

gem 'configurate', '0.2.0'

# Cross-origin resource sharing

gem 'rack-cors', '0.2.9', :require => 'rack/cors'

# CSS

gem 'bootstrap-sass', '2.3.2.2'
gem 'compass-rails',  '2.0.0'
gem 'sass-rails',     '4.0.4'
gem 'autoprefixer-rails', '4.0.2.1'

# Database

ENV['DB'] ||= 'mysql'

gem 'mysql2', '0.3.17' if ENV['DB'] == 'all' || ENV['DB'] == 'mysql'
gem 'pg',     '0.17.1' if ENV['DB'] == 'all' || ENV['DB'] == 'postgres'

gem 'activerecord-import', '0.6.0'
gem 'foreigner',           '1.6.1'

# File uploading

gem 'carrierwave', '0.10.0'
gem 'fog',         '1.25.0'
gem 'mini_magick', '4.0.1'
gem 'remotipart',  '1.2.1'

# GUID generation
gem 'uuid', '2.3.7'

# Icons

gem 'entypo-rails', '2.2.2'

# JavaScript

gem 'backbone-on-rails',                                '1.1.2'
gem 'handlebars_assets',                                '0.18.0'
gem 'jquery-rails',                                     '3.1.2'
gem 'rails-assets-jquery',                              '1.11.1' # Should be kept in sync with jquery-rails
gem 'js_image_paths',                                   '0.0.1'
gem 'js-routes',                                        '0.9.9'
gem 'rails-assets-punycode',                            '1.3.2'
gem 'rails-assets-markdown-it',                         '3.0.6'
gem 'rails-assets-markdown-it-hashtag',                 '0.2.3'
gem 'rails-assets-markdown-it-diaspora-mention',        '0.2.0'
gem 'rails-assets-markdown-it-sanitizer',               '0.2.1'
gem 'rails-assets-markdown-it--markdown-it-for-inline', '0.1.0'
gem 'rails-assets-markdown-it-sub',                     '0.1.0'
gem 'rails-assets-markdown-it-sup',                     '0.1.0'

# jQuery plugins

gem 'rails-assets-jeresig--jquery.hotkeys', '0.2.0'
gem 'rails-assets-jquery-idletimer',        '1.0.1'
gem 'rails-assets-jquery-placeholder',      '2.0.8'
gem 'rails-assets-jquery-textchange',       '0.2.3'
gem 'rails-assets-perfect-scrollbar',       '0.5.7'

# Localization

gem 'http_accept_language', '2.0.2'
gem 'i18n-inflector-rails', '1.0.7'
gem 'rails-i18n',           '4.0.3'

# Mail

gem 'markerb',             '1.0.2'
gem 'messagebus_ruby_api', '1.0.3'

# Parsing

gem 'nokogiri',          '1.6.4.1'
gem 'redcarpet',         '3.2.0'
gem 'twitter-text',      '1.10.0'
gem 'roxml',             '3.1.6'
gem 'ruby-oembed',       '0.8.11'
gem 'open_graph_reader', '0.4.0'


# Services

gem 'omniauth',          '1.2.2'
gem 'omniauth-facebook', '1.6.0'
gem 'omniauth-tumblr',   '1.1'
gem 'omniauth-twitter',  '1.0.1'
gem 'twitter',           '4.8.1'
gem 'omniauth-wordpress','0.2.1'

# XMPP chat dependencies
gem 'diaspora-vines',             '~> 0.1.25'
gem 'rails-assets-diaspora_jsxc', '~> 0.0.9'

# Tags

gem 'acts-as-taggable-on', '3.4.2'

# URIs and HTTP

gem 'addressable',        '2.3.6', :require => 'addressable/uri'
gem 'faraday',            '0.9.0'
gem 'faraday_middleware', '0.9.1'
gem 'faraday-cookie_jar', '0.0.6'
gem 'typhoeus',           '0.6.9'

# Views

gem 'gon',                     '5.2.3'
gem 'haml',                    '4.0.5'
gem 'mobile-fu',               '1.3.1'
gem 'will_paginate',           '3.0.7'
gem 'rails-timeago',           '2.11.0'

# Workarounds
# https://github.com/rubyzip/rubyzip#important-note
gem 'zip-zip'

# Prevent occasions where minitest is not bundled in
# packaged versions of ruby. See following issues/prs:
# https://github.com/gitlabhq/gitlabhq/issues/3826
# https://github.com/gitlabhq/gitlabhq/pull/3852
# https://github.com/discourse/discourse/pull/238
gem 'minitest'

# Serializers
gem 'active_model_serializers'

# Windows and OSX have an execjs compatible runtime built-in, Linux users should
# install Node.js or use 'therubyracer'.
#
# See https://github.com/sstephenson/execjs#readme for more supported runtimes

# gem 'therubyracer', :platform => :ruby

group :production do # we don't install these on travis to speed up test runs

  # Administration

  gem 'rails_admin', '0.6.5'

  # Analytics

  gem 'rack-google-analytics', '1.2.0'
  gem 'rack-piwik',            '0.3.0',  :require => 'rack/piwik'

  # Click-jacking protection

  gem 'rack-protection', '1.5.2'

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
  gem 'guard-cucumber', '1.5.1'
  gem 'guard-rspec',    '4.3.1'
  gem 'guard',          '2.10.0', :require => false
  gem 'rb-fsevent',     '0.9.4', :require => false
  gem 'rb-inotify',     '0.9.5', :require => false

  # Linters
  gem 'jshint', '1.3.1'

  # Preloading environment

  gem 'spring', '1.3.1'
  gem 'spring-commands-rspec', '1.0.2'
  gem 'spring-commands-cucumber', '1.0.1'

  # Debugging
  gem 'pry'
  gem 'pry-debundle'
  gem 'pry-byebug'
end

group :test do
  # RSpec (unit tests, some integration tests)

  gem 'fixture_builder',   '0.3.6'
  gem 'fuubar',            '2.0.0'
  gem 'rspec-instafail',   '0.2.5', :require => false
  gem 'test_after_commit', '0.4.0'

  # Cucumber (integration tests)

  gem 'capybara',           '2.4.4'
  gem 'database_cleaner',   '1.3.0'
  gem 'selenium-webdriver', '2.44.0'

  # General helpers

  gem 'factory_girl_rails', '4.5.0'
  gem 'timecop',            '0.7.1'
  gem 'webmock',            '1.20.4', :require => false
end


group :development, :test do
  # RSpec (unit tests, some integration tests)
  gem 'rspec-rails',     '3.1.0'

  # Cucumber (integration tests)
  gem 'cucumber-rails',     '1.4.2', :require => false

  # Jasmine (client side application tests (JS))
  gem 'jasmine',                   '2.2.0'
  gem 'jasmine-jquery-rails',      '2.0.3'
  gem 'rails-assets-jasmine-ajax', '3.0.0'
  gem 'sinon-rails',               '1.10.3'
end
