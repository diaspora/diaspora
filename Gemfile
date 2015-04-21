source "https://rubygems.org"

gem "rails", "4.2.1"

# Legacy Rails features, remove me!

# caches_page
gem "actionpack-action_caching"
gem "actionpack-page_caching"

# responders (class level)
gem "responders", "2.1.0"

# Appserver

gem "unicorn", "4.8.3", require: false

# API and JSON

gem "acts_as_api", "0.4.2"
gem "json",        "1.8.2"

# Authentication

gem "devise", "3.4.1"
gem "devise_lastseenable", "0.0.4"
gem "devise-token_authenticatable", "~> 0.3.0"

# Captcha

gem "simple_captcha2", "0.3.4", require: "simple_captcha"

# Background processing

gem "sidekiq", "3.3.3"
gem "sinatra", "1.4.6"

# Scheduled processing

gem "sidetiq", "0.6.3"

# Compression

gem "uglifier", "2.7.1"

# Configuration

gem "configurate", "0.2.0"

# Cross-origin resource sharing

gem "rack-cors", "0.3.1", require: "rack/cors"

# CSS

gem "bootstrap-sass", "2.3.2.2"
gem "compass-rails",  "2.0.4"
gem "sass-rails",     "5.0.1"
gem "autoprefixer-rails", "5.1.7.1"

# Database

ENV["DB"] ||= "mysql"

gem "mysql2", "0.3.18" if ENV["DB"] == "all" || ENV["DB"] == "mysql"
gem "pg",     "0.18.1" if ENV["DB"] == "all" || ENV["DB"] == "postgres"

gem "activerecord-import", "0.7.0"

# File uploading

gem "carrierwave", "0.10.0"
gem "fog",         "1.28.0"
gem "mini_magick", "4.2.0"
gem "remotipart",  "1.2.1"

# GUID generation
gem "uuid", "2.3.7"

# Icons

gem "entypo-rails", "2.2.2"

# JavaScript

gem "backbone-on-rails",                                "1.1.2"
gem "handlebars_assets",                                "0.20.1"
gem "jquery-rails",                                     "3.1.2"
gem "js_image_paths",                                   "0.0.2"
gem "js-routes",                                        "1.0.0"

source "https://rails-assets.org" do
  gem "rails-assets-jquery",                              "1.11.1" # Should be kept in sync with jquery-rails

  gem "rails-assets-markdown-it",                         "4.2.0"
  gem "rails-assets-markdown-it-hashtag",                 "0.3.0"
  gem "rails-assets-markdown-it-diaspora-mention",        "0.3.0"
  gem "rails-assets-markdown-it-sanitizer",               "0.3.0"
  gem "rails-assets-markdown-it--markdown-it-for-inline", "0.1.0"
  gem "rails-assets-markdown-it-sub",                     "1.0.0"
  gem "rails-assets-markdown-it-sup",                     "1.0.0"

  # jQuery plugins

  gem "rails-assets-jeresig--jquery.hotkeys", "0.2.0"
  gem "rails-assets-jquery-idletimer",        "1.0.1"
  gem "rails-assets-jquery-placeholder",      "2.1.1"
  gem "rails-assets-jquery-textchange",       "0.2.3"
  gem "rails-assets-perfect-scrollbar",       "0.5.9"
end

# Localization

gem "http_accept_language", "2.0.5"
gem "i18n-inflector-rails", "1.0.7"
gem "rails-i18n",           "4.0.4"

# Mail

gem "markerb",             "1.0.2"
gem "messagebus_ruby_api", "1.0.3"

# Parsing

gem "nokogiri",          "1.6.6.2"
gem "redcarpet",         "3.2.3"
gem "twitter-text",      "1.11.0"
gem "roxml",             "3.1.6"
gem "ruby-oembed",       "0.8.12"
gem "open_graph_reader", "0.5.0"

# Services

gem "omniauth",           "1.2.2"
gem "omniauth-facebook",  "1.6.0"
gem "omniauth-tumblr",    "1.1"
gem "omniauth-twitter",   "1.0.1"
gem "twitter",            "4.8.1"
gem "omniauth-wordpress", "0.2.1"

# Serializers

gem "active_model_serializers", "0.9.3"

# XMPP chat dependencies
gem "diaspora-vines",             "~> 0.1.27"
gem "rails-assets-diaspora_jsxc", "~> 0.1.1", source: "https://rails-assets.org"

# Tags

gem "acts-as-taggable-on", "3.5.0"

# URIs and HTTP

gem "addressable",        "2.3.7", require: "addressable/uri"
gem "faraday",            "0.9.1"
gem "faraday_middleware", "0.9.1"
gem "faraday-cookie_jar", "0.0.6"
gem "typhoeus",           "0.7.1"

# Views

gem "gon",                     "5.2.3"
gem "haml",                    "4.0.6"
gem "mobile-fu",               "1.3.1"
gem "will_paginate",           "3.0.7"
gem "rails-timeago",           "2.11.0"

# Workarounds
# https://github.com/rubyzip/rubyzip#important-note
gem "zip-zip"

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

  gem "rails_admin", "0.6.7"

  # Analytics

  gem "rack-google-analytics", "1.2.0"
  gem "rack-piwik",            "0.3.0",  require: "rack/piwik"

  # Click-jacking protection

  gem "rack-protection", "1.5.3"

  # Process management

  gem "foreman", "0.62"

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
  gem "guard-rspec",    "4.5.0"
  gem "guard-rubocop",  "1.2.0"
  gem "guard",          "2.12.5", require: false
  gem "rb-fsevent",     "0.9.4", require: false
  gem "rb-inotify",     "0.9.5", require: false

  # Linters
  gem "jshintrb", "0.3.0"
  gem "rubocop",  "0.29.1"

  # Preloading environment

  gem "spring", "1.3.3"
  gem "spring-commands-rspec", "1.0.4"
  gem "spring-commands-cucumber", "1.0.1"

  # Debugging
  gem "pry"
  gem "pry-debundle"
  gem "pry-byebug"
end

group :test do
  # RSpec (unit tests, some integration tests)

  gem "fixture_builder",   "0.3.6"
  gem "fuubar",            "2.0.0"
  gem "rspec-instafail",   "0.2.6", require: false
  gem "test_after_commit", "0.4.1"

  # Cucumber (integration tests)

  gem "capybara",           "2.4.4"
  gem "database_cleaner" ,  "1.4.1"
  gem "selenium-webdriver", "2.45.0"

  # General helpers

  gem "factory_girl_rails", "4.5.0"
  gem "timecop",            "0.7.3"
  gem "webmock",            "1.20.4", require: false
  gem "shoulda-matchers",   "2.8.0", require: false
end

group :development, :test do
  # RSpec (unit tests, some integration tests)
  gem "rspec-rails",     "3.2.1"

  # Cucumber (integration tests)
  gem "cucumber-rails",     "1.4.2", require: false

  # Jasmine (client side application tests (JS))
  gem "jasmine",                   "2.2.0"
  gem "jasmine-jquery-rails",      "2.0.3"
  gem "rails-assets-jasmine-ajax", "3.1.0", source: "https://rails-assets.org"
  gem "sinon-rails",               "1.10.3"
end
