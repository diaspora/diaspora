# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "6.1.7.8"

# needed for actionmailer, can be removed when upgrading to rails 7
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false

# Legacy Rails features, remove me!
# responders (class level)
gem "responders", "3.1.1"

# Appserver

gem "puma", "6.4.2", require: false

# Federation

gem "diaspora_federation-json_schema", "1.1.0"
gem "diaspora_federation-rails",       "1.1.0"

# API and JSON

gem "acts_as_api", "1.0.1"
gem "json",        "2.7.2"
gem "json-schema", "4.3.0"
gem "yajl-ruby",   "1.4.3"

# Authentication

gem "devise", "4.9.4"
gem "devise_lastseenable", "0.0.6"
gem "devise-two-factor", "4.1.0"
gem "rqrcode", "2.2.0"

# Captcha

gem "simple_captcha2", "0.5.0", require: "simple_captcha"

# Background processing

gem "redis", "4.8.1"
gem "sidekiq", "6.5.12"

# Scheduled processing

gem "sidekiq-cron", "1.12.0"

# Compression

gem "terser", "1.2.2"

# Configuration

gem "configurate", "0.6.0"
gem "toml-rb", "3.0.1"

# Cross-origin resource sharing

gem "rack-cors", "2.0.2", require: "rack/cors"

# CSS

gem "autoprefixer-rails",     "10.4.16.0"
gem "bootstrap-sass",         "3.4.1"
gem "bootstrap-switch-rails", "3.3.3" # 3.3.4 and 3.3.5 is broken, see https://github.com/Bttstrp/bootstrap-switch/issues/691
gem "sassc-rails",            "2.1.2"
gem "sprockets-rails",        "3.4.2"

# Database

group :mysql, optional: true do
  gem "mysql2", "0.5.6"
end
group :postgresql, optional: true do
  gem "pg",     "1.5.6"
end

gem "activerecord-import", "1.7.0"

# File uploading

gem "carrierwave", "3.0.7"
gem "fog-aws",     "3.22.0"
gem "mini_magick", "4.12.0"

# GUID generation
gem "uuid", "2.3.9"

# JavaScript

gem "babel-transpiler",  "0.7.0"
gem "handlebars_assets", "0.23.9"
gem "jquery-rails",      "4.6.0"
gem "jquery-ui-rails",   "7.0.0"
gem "js_image_paths",    "0.2.0"
gem "js-routes",         "2.2.8"

# Localization

gem "http_accept_language", "2.1.1"
gem "rails-i18n",           "7.0.9"

# Map
gem "leaflet-rails", "1.9.4"

# Parsing

gem "nokogiri",          "1.16.5"
gem "open_graph_reader", "0.7.2" # also update User-Agent in features/support/webmock.rb and open_graph_cache_spec.rb
gem "redcarpet",         "3.6.0"
gem "ruby-oembed",       "0.17.0"
gem "twitter-text",      "3.1.0"

# Rate limitting

gem "rack-attack", "6.7.0"

# RTL support

gem "string-direction", "1.2.2"

# Security Headers

gem "secure_headers", "6.5.0"

# Services

gem "omniauth",                       "2.1.2"
gem "omniauth-rails_csrf_protection", "1.0.2"
gem "omniauth-tumblr",                "1.2"
gem "omniauth-twitter",               "1.4.0"
gem "omniauth-wordpress",             "0.2.2"
gem "twitter",                        "8.0.0"

# OpenID Connect
gem "openid_connect", "2.3.0"

# Serializers

gem "active_model_serializers", "0.9.12"

# Tags

gem "acts-as-taggable-on", "10.0.0"

# URIs and HTTP

gem "addressable",              "2.8.6", require: "addressable/uri"
gem "faraday",                  "2.9.0"
gem "faraday-cookie_jar",       "0.0.7"
gem "faraday-follow_redirects", "0.3.0"
gem "faraday-typhoeus",         "1.1.0", require: false
gem "typhoeus",                 "1.4.1"

# Views

gem "gon",                     "6.4.0"
gem "hamlit",                  "3.0.3"
gem "mobile-fu",               "1.4.0"
gem "rails-timeago",           "2.20.0"
gem "will_paginate",           "4.0.0"

# Logging

gem "logging-rails", "0.6.0", require: "logging/rails"

# Reading and writing zip files

gem "rubyzip", "2.3.2", require: "zip"

# Prevent occasions where minitest is not bundled in
# packaged versions of ruby. See following issues/prs:
# https://github.com/gitlabhq/gitlabhq/issues/3826
# https://github.com/gitlabhq/gitlabhq/pull/3852
# https://github.com/discourse/discourse/pull/238
gem "minitest", "5.23.1"

gem "versionist", "2.0.1"

group :production do # we don"t install these on travis to speed up test runs
  # Analytics

  gem "rack-google-analytics", "1.2.0"
  gem "rack-piwik",            "0.3.0",  require: "rack/piwik"

  # Process management

  gem "foreman", "0.88.1", require: false

  # Redirects

  gem "rack-rewrite", "1.5.1", require: false
  gem "rack-ssl",     "1.4.1", require: "rack/ssl"

  # Third party asset hosting

  gem "asset_sync", "2.19.1", require: false
end

group :development do
  # Linters
  gem "haml_lint",      "0.58.0", require: false
  gem "pronto",         "0.11.2", require: false
  gem "pronto-eslint",  "0.11.1", require: false
  gem "pronto-haml",    "0.11.1", require: false
  gem "pronto-rubocop", "0.11.5", require: false
  gem "pronto-scss",    "0.11.0", require: false
  gem "rubocop",        "1.64.0", require: false
  gem "rubocop-rails",  "2.25.0", require: false

  gem "faraday-retry", require: false # used by pronto/octokit

  # Debugging
  gem "pry"
  gem "pry-byebug"

  # test coverage
  gem "simplecov", "0.22.0", require: false

  gem "turbo_dev_assets", "0.0.2"

  gem "listen", "3.9.0"
end

group :test do
  # RSpec (unit tests, some integration tests)

  gem "fixture_builder",   "0.5.2"
  gem "fuubar",            "2.5.1"
  gem "rspec-json_expectations", "~> 2.1"

  # Cucumber (integration tests)

  gem "capybara",         "3.40.0"
  gem "cuprite",          "0.15"
  gem "database_cleaner-active_record", "2.1.0"

  gem "cucumber-api-steps", "0.14", require: false

  # General helpers

  gem "factory_bot_rails", "6.4.3"
  gem "shoulda-matchers",  "6.2.0"
  gem "timecop",           "0.9.8"
  gem "webmock",           "3.23.1", require: false

  gem "diaspora_federation-test", "1.1.0"
end

group :development, :test do
  # RSpec (unit tests, some integration tests)
  gem "rspec-rails", "6.1.2"

  # Cucumber (integration tests)
  gem "cucumber-rails", "3.0.0", require: false

  # Jasmine (client side application tests (JS))
  gem "chrome_remote",             "0.3.0"
  gem "jasmine",                   "3.10.0"
  gem "jasmine-jquery-rails",      "2.0.3"
  gem "sinon-rails",               "1.15.0"

  # For `assigns` in controller specs
  gem "rails-controller-testing", "1.0.5"
end
