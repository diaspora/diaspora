source 'http://rubygems.org'

gem 'rails', '3.0.11'

gem 'bundler', '>= 1.0.0'
gem 'foreman'

gem 'thin', '~> 1.3.1', :require => false

# authentication

gem 'devise', '~> 1.3.1'
gem 'devise_invitable', '0.5.0'
gem 'jwt', "0.1.3"
gem 'oauth2-provider', '0.0.16'

gem 'omniauth', '1.0.1'
gem 'omniauth-facebook'
gem 'omniauth-tumblr'
gem 'omniauth-twitter'

gem 'twitter', '2.0.1'

# backups

gem 'cloudfiles', '1.4.10', :require => false

# chef

gem 'chef', '0.9.12', :require => false
gem 'ohai', '0.5.8', :require => false

# configuration

gem 'settingslogic', '2.0.6'

# database

gem 'activerecord-import'
gem 'foreigner', '0.9.1'
gem 'mysql2', '0.2.17' if ENV['DB'].nil? || ENV['DB'] == 'all' || ENV['DB'] == 'mysql'
gem 'pg' if ENV['DB'] == 'all' || ENV['DB'] == 'postgres'
gem 'sqlite3' if ENV['DB'] == 'all' || ENV['DB'] == 'sqlite'

# file uploading

gem 'carrierwave', '0.5.8'
gem 'fog'
gem 'fastercsv', '1.5.4', :require => false
gem 'mini_magick', '3.3'
gem 'rest-client', '1.6.1'

gem 'jammit', '0.6.5'

# JSON and API

gem 'json', '1.4.6'
gem 'vanna', :git => 'git://github.com/MikeSofaer/vanna.git'

# localization

gem 'i18n-inflector-rails', '~> 1.0'
gem 'rails-i18n'

# parsing

gem 'nokogiri', '~> 1.5.0'
gem 'redcarpet', "2.0.0"
gem 'roxml', :git => 'git://github.com/Empact/roxml.git', :ref => '7ea9a9ffd2338aaef5b0'
gem 'ruby-oembed'

# queue

gem 'resque', '1.19.0'
gem 'resque-ensure-connected'
gem 'resque-timeout', '1.0.0'
gem 'SystemTimer', '1.2.3', :platforms => :ruby_18

# reporting

gem 'hoptoad_notifier'
gem 'newrelic_rpm', :require => false

#mail

gem 'messagebus_ruby_api', '0.4.8'

# tags

gem 'acts-as-taggable-on', :git => 'git://github.com/diaspora/acts-as-taggable-on.git'

# URIs and HTTP

gem 'addressable', '2.2.4', :require => 'addressable/uri'
gem 'http_accept_language', :git => 'git://github.com/iain/http_accept_language.git', :ref => '0b78aa7849fc90cf9e12'
gem 'typhoeus'

# views

gem 'haml', '3.1.4'
gem 'mobile-fu'
gem 'sass', '3.1.11'
gem 'will_paginate', '3.0.pre2'
gem 'client_side_validations'

# web

gem 'faraday'
gem 'faraday-stack'

# web sockets

gem 'em-synchrony', :platforms => :ruby_19
gem 'em-websocket'

### GROUPS ####

group :test, :development do
  gem 'jasmine', '1.1.0.rc3'
end

group :test do
  gem 'capybara', '~> 1.1.2'
  gem 'cucumber-rails', '1.2.1'
  gem 'cucumber-api-steps', '0.6', :require => false
  gem 'database_cleaner', '0.7.0'
  gem 'diaspora-client', :git => 'git://github.com/diaspora/diaspora-client.git'
                          #"0.1.0", #:path => '~/workspace/diaspora-client'
  gem 'factory_girl_rails'
  gem 'fixture_builder', '0.3.1'
  gem 'fuubar', '0.0.5'
  gem 'mongrel', :require => false, :platforms => :ruby_18
  gem 'rspec', '>= 2.0.0'
  gem 'rspec-core', '2.6.0'
  gem 'rspec-instafail', '>= 0.1.7', :require => false
  gem 'rspec-rails', '>= 2.0.0'
  gem 'selenium-webdriver', '~> 2.14.0'
  gem 'webmock', :require => false
  gem 'sqlite3'
  gem 'mock_redis'
end

group :development do
  gem 'capistrano', '2.5.19', :require => false
  gem 'capistrano_colors', :require => false
  gem 'capistrano-ext', '1.2.1', :require => false
  gem 'linecache', '0.43', :platforms => :mri_18
  gem 'parallel_tests'
  gem 'ruby-debug-base19', '0.11.23' if RUBY_VERSION.include? '1.9.1'
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'ruby-debug', :platforms => :mri_18
  gem 'sod', :git => 'git://github.com/MikeSofaer/sod.git', :require => false
  gem 'yard'
end
