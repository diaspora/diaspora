source "https://rubygems.org"

gem "rails", "4.2.5"

# Legacy Rails features, remove me!
# responders (class level)
gem "responders", "2.1.1"

# Appserver

gem "unicorn", "5.0.1", require: false

# Federation

gem "diaspora_federation-rails", "0.0.11"

# API and JSON

gem "acts_as_api", "0.4.2"
gem "json",        "1.8.3"
gem "json-schema", "2.5.2"

# Authentication

gem "devise", "3.5.3"
gem "devise_lastseenable", "0.0.6"
gem "devise-token_authenticatable", "~> 0.4.0"

# Captcha

gem "simple_captcha2", "0.3.4", require: "simple_captcha"

# Background processing

gem "sidekiq", "3.4.2"
gem "sinatra", "1.4.6"

# Scheduled processing

gem "sidetiq", "0.6.3"

# Compression

gem "uglifier", "2.7.2"

# Configuration

gem "configurate", "0.3.1"

# Cross-origin resource sharing

gem "rack-cors", "0.4.0", require: "rack/cors"

# CSS

gem "bootstrap-sass", "2.3.2.2"
gem "compass-rails",  "2.0.5"
gem "sass-rails",     "5.0.4"
gem "autoprefixer-rails", "6.2.2"

# Database

ENV["DB"] ||= "mysql"

gem "mysql2", "0.3.20" if ENV["DB"] == "all" || ENV["DB"] == "mysql"
gem "pg",     "0.18.4" if ENV["DB"] == "all" || ENV["DB"] == "postgres"

gem "activerecord-import", "0.10.0"

# File uploading

gem "carrierwave", "0.10.0"
gem "fog",         "1.37.0"
gem "mini_magick", "4.3.6"
gem "remotipart",  "1.2.1"

# GUID generation
gem "uuid", "2.3.8"

# Icons

gem "entypo-rails", "2.2.3"

# JavaScript

gem "backbone-on-rails", "1.2.0.0"
gem "handlebars_assets", "0.22.0"
gem "jquery-rails",      "4.0.5"
gem "jquery-ui-rails",   "5.0.5"
gem "js_image_paths",    "0.0.2"
gem "js-routes",         "1.2.0"

source "https://rails-assets.org" do
  gem "rails-assets-jquery",                              "1.11.2" # Should be kept in sync with jquery-rails

  gem "rails-assets-markdown-it",                         "5.0.2"
  gem "rails-assets-markdown-it-hashtag",                 "0.4.0"
  gem "rails-assets-markdown-it-diaspora-mention",        "0.4.0"
  gem "rails-assets-markdown-it-sanitizer",               "0.4.1"
  gem "rails-assets-markdown-it--markdown-it-for-inline", "0.1.1"
  gem "rails-assets-markdown-it-sub",                     "1.0.0"
  gem "rails-assets-markdown-it-sup",                     "1.0.0"
  gem "rails-assets-highlightjs",                         "9.0.0"

  # jQuery plugins

  gem "rails-assets-jeresig--jquery.hotkeys",       "0.2.0"
  gem "rails-assets-jquery-placeholder",            "2.3.1"
  gem "rails-assets-jquery-textchange",             "0.2.3"
  gem "rails-assets-perfect-scrollbar",             "0.6.8"
  gem "rails-assets-jakobmattsson--jquery-elastic", "1.6.11"
end

gem "facebox-rails", "0.2.0"

# Localization

gem "http_accept_language", "2.0.5"
gem "i18n-inflector-rails", "1.0.7"
gem "rails-i18n",           "4.0.8"

# Mail

gem "markerb",             "1.1.0"
gem "messagebus_ruby_api", "1.0.3"

# Parsing

gem "nokogiri",          "1.6.7.1"
gem "redcarpet",         "3.3.4"
gem "twitter-text",      "1.13.0"
gem "roxml",             "3.1.6"
gem "ruby-oembed",       "0.9.0"
gem "open_graph_reader", "0.6.1"

# Services

gem "omniauth",           "1.3.1"
gem "omniauth-facebook",  "3.0.0"
gem "omniauth-tumblr",    "1.2"
gem "omniauth-twitter",   "1.2.1"
gem "twitter",            "5.15.0"
gem "omniauth-wordpress", "0.2.2"

# Serializers

gem "active_model_serializers", "0.9.3"

# XMPP chat dependencies
gem "diaspora-vines",             "~> 0.2.0.develop"
gem "rails-assets-diaspora_jsxc", "~> 0.1.4", source: "https://rails-assets.org"

# Tags

gem "acts-as-taggable-on", "3.5.0"

# URIs and HTTP

gem "addressable",        "2.3.8", require: "addressable/uri"
gem "faraday",            "0.9.2"
gem "faraday_middleware", "0.10.0"
gem "faraday-cookie_jar", "0.0.6"
gem "typhoeus",           "0.8.0"

# Views

gem "gon",                     "6.0.1"
gem "haml",                    "4.0.7"
gem "mobile-fu",               "1.3.1"
gem "will_paginate",           "3.0.7"
gem "rails-timeago",           "2.11.0"

# Logging

gem "logging-rails", "0.5.0", require: "logging/rails"

# Reading and writing zip files

gem "rubyzip", "1.1.7"

# Prevent occasions where minitest is not bundled in
# packaged versions of ruby. See following issues/prs:
# https://github.com/gitlabhq/gitlabhq/issues/3826
# https://github.com/gitlabhq/gitlabhq/pull/3852
# https://github.com/discourse/discourse/pull/238
gem "minitest"

# Windows and OSX have an execjs compatible runtime built-in, Linux users should
# install Node.js or use "therubyracer".
#
# See https://github.com/sstephenson/execjs#readme for more supported runtimes

# gem "therubyracer", :platform => :ruby

group :production do # we don"t install these on travis to speed up test runs
  # Administration

  gem "rails_admin", "0.8.1"

  # Analytics

  gem "rack-google-analytics", "1.2.0"
  gem "rack-piwik",            "0.3.0",  require: "rack/piwik"

  # Click-jacking protection

  gem "rack-protection", "1.5.3"

  # Process management

  gem "eye", "0.7"

  # Redirects

  gem "rack-rewrite", "1.5.1", require: false
  gem "rack-ssl",     "1.4.1", require: "rack/ssl"

  # Third party asset hosting

  gem "asset_sync", "1.1.0", require: false
end

group :development do
  # Automatic test runs
  gem "guard-cucumber", "1.5.4"
  gem "guard-jshintrb", "1.1.1"
  gem "guard-rspec",    "4.6.4"
  gem "guard-rubocop",  "1.2.0"
  gem "guard",          "2.13.0", require: false
  gem "rb-fsevent",     "0.9.6", require: false
  gem "rb-inotify",     "0.9.5", require: false

  # Linters
  gem "jshintrb", "0.3.0"
  gem "rubocop",  "0.35.1"

  # Preloading environment

  gem "spring", "1.6.1"
  gem "spring-commands-rspec", "1.0.4"
  gem "spring-commands-cucumber", "1.0.1"

  # Debugging
  gem "pry"
  gem "pry-debundle"
  gem "pry-byebug"

  # test coverage
  gem "simplecov", "0.11.1", require: false
end

group :test do
  # RSpec (unit tests, some integration tests)

  gem "fixture_builder",   "0.4.1"
  gem "fuubar",            "2.0.0"
  gem "rspec-instafail",   "0.4.0", require: false
  gem "test_after_commit", "0.4.2"

  # Cucumber (integration tests)

  gem "capybara",           "2.5.0"
  gem "database_cleaner" ,  "1.5.1"
  gem "selenium-webdriver", "2.47.1"

  # General helpers

  gem "factory_girl_rails", "4.5.0"
  gem "timecop",            "0.8.0"
  gem "webmock",            "1.22.3", require: false
  gem "shoulda-matchers",   "3.0.1"

  gem "diaspora_federation-test", "0.0.11"
end

group :development, :test do
  # RSpec (unit tests, some integration tests)
  gem "rspec-rails",     "3.3.3"

  # Cucumber (integration tests)
  gem "cucumber-rails",     "1.4.2", require: false

  # Jasmine (client side application tests (JS))
  gem "jasmine",                   "2.4.0"
  gem "jasmine-jquery-rails",      "2.0.3"
  gem "rails-assets-jasmine-ajax", "3.2.0", source: "https://rails-assets.org"
  gem "sinon-rails",               "1.15.0"

  # silence assets
  gem "quiet_assets", "1.1.0"
end
