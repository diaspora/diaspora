source 'http://rubygems.org'

gem 'rails', '3.0.10'

gem 'bundler', '>= 1.0.0'
gem 'foreman'

gem 'thin', '1.2.11', :require => false

# authentication

gem 'devise', '~> 1.3.1'
gem 'devise_invitable', '0.5.0'
gem 'jwt', "0.1.3"
gem 'oauth2-provider', '0.0.16'
gem 'omniauth', '0.2.6'
gem 'twitter', '1.5.0'

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
gem 'mysql2', '0.2.13' if ENV['DB'].nil? || ENV['DB'] == 'all' || ENV['DB'] == 'mysql'
gem 'pg' if ENV['DB'] == 'all' || ENV['DB'] == 'postgres'
gem 'sqlite3' if ENV['DB'] == 'all' || ENV['DB'] == 'sqlite'

# file uploading

gem 'aws', '2.3.32' # upgrade to 2.4 breaks 1.8 >.<
gem 'carrierwave', '0.5.2'
gem 'excon', '0.2.4'
gem 'fastercsv', '1.5.4', :require => false
gem 'fog', '0.3.25'
gem 'jammit', '0.5.4'
gem 'mini_magick', '3.2'
gem 'rest-client', '1.6.1'
gem 'typhoeus'

# JSON and API

gem 'json', '1.4.6'
gem 'vanna', :git => 'git://github.com/MikeSofaer/vanna.git'

# localization

gem 'i18n-inflector-rails', '~> 1.0'
gem 'rails-i18n'

# parsing

gem 'nokogiri'
gem 'redcarpet', "2.0.0b5"
gem 'roxml', :git => 'git://github.com/Empact/roxml.git', :ref => '7ea9a9ffd2338aaef5b0'

# queue

gem 'resque', '1.10.0'
gem 'resque-ensure-connected'
gem 'resque-timeout', '1.0.0'
gem 'SystemTimer', '1.2.1', :platforms => :ruby_18

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

# views

gem 'haml', '3.1.2'
gem 'mobile-fu'
gem 'sass', '3.1.7'
gem 'will_paginate', '3.0.pre2'

# web

gem 'faraday'
gem 'faraday-stack'

# web sockets

gem 'em-synchrony', :platforms => :ruby_19
gem 'em-websocket', :git => 'git://github.com/igrigorik/em-websocket', :ref => 'e278f5a1c4db60be7485'

### GROUPS ####

group :test, :development do
  gem 'jasmine', '1.1.0.rc3'
end

group :test do
  gem 'capybara', '~> 0.3.9'
  gem 'cucumber-rails', '0.3.2'
  gem 'database_cleaner', '0.6.0'
  gem 'diaspora-client', :git => 'git://github.com/diaspora/diaspora-client.git'
                          #"0.1.0", #:path => '~/workspace/diaspora-client'
  gem 'factory_girl_rails'
  gem 'fixture_builder', '0.3.0'
  gem 'fuubar'
  gem 'mongrel', :require => false, :platforms => :ruby_18
  gem 'rspec', '>= 2.0.0'
  gem 'rspec-core', '2.6.0'
  gem 'rspec-instafail', '>= 0.1.7', :require => false
  gem 'rspec-rails', '>= 2.0.0'
  gem "selenium-webdriver", "~> 2.7.0"
  gem 'webmock', :require => false
  gem 'sqlite3'
  gem 'mock_redis'
end

group :development do
  gem 'capistrano', '2.5.19', :require => false
  gem 'capistrano-ext', '1.2.1', :require => false
  gem 'linecache', '0.43', :platforms => :mri_18
  gem 'parallel_tests'
  gem 'ruby-debug-base19', '0.11.23' if RUBY_VERSION.include? '1.9.1'
  gem 'ruby-debug19', :platforms => :ruby_19
  gem 'ruby-debug', :platforms => :mri_18
  gem 'sod', :git => 'git://github.com/MikeSofaer/sod.git', :require => false
  gem 'yard'
end
