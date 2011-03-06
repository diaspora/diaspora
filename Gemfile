source 'http://rubygems.org'

gem 'mysql2', '0.2.6'
gem 'rails', '3.0.3'
gem 'foreigner', '0.9.1'

gem 'bundler', '>= 1.0.0'
gem 'chef', '0.9.12', :require => false

gem 'nokogiri', '1.4.3.1'

gem "fog", '0.3.25'
gem "excon", "0.2.4"

#Security
gem 'devise', '1.1.3'
gem 'devise_invitable', :git => 'git://github.com/zhitomirskiyi/devise_invitable.git', :branch => '0.3.5'

#Authentication
gem 'omniauth', '0.1.6'
gem 'twitter', :git => 'git://github.com/jnunemaker/twitter.git', :ref => 'ef122bbb280e229ed343'

#Views
gem 'haml', '3.0.25'
gem 'will_paginate', '3.0.pre2'

#Statistics
gem 'googlecharts'

#Inflected translations
gem 'i18n-inflector-rails', '~> 1.0'

#Uncatagorized
gem 'roxml', :git => 'git://github.com/Empact/roxml.git', :ref => '7ea9a9ffd2338aaef5b0'
gem 'addressable', '2.2.2', :require => 'addressable/uri'
gem 'json', '1.4.6'
gem 'http_accept_language', :git => 'git://github.com/iain/http_accept_language.git', :ref => '0b78aa7849fc90cf9e12'

gem 'thin', '1.2.8', :require => false

#Websocket
gem 'em-websocket', :git => 'git://github.com/igrigorik/em-websocket', :ref => 'e278f5a1c4db60be7485'

#File uploading
gem 'carrierwave', '0.5.2'
gem 'mini_magick', '3.2'
gem 'aws', '2.3.32' # upgrade to 2.4 breaks 1.8 >.<
gem 'fastercsv', '1.5.4', :require => false
gem 'jammit', '0.5.4'
gem 'rest-client', '1.6.1'
gem 'typhoeus'
#Backups
gem 'cloudfiles', '1.4.10', :require => false

#Queue
gem 'resque', '1.10.0'
gem 'SystemTimer', '1.2.1' unless RUBY_VERSION.include? '1.9' || RUBY_PLATFORM =~ 'win32'

group :development do
  gem 'capistrano', '2.5.19', :require => false
  gem 'capistrano-ext', '1.2.1', :require => false
end

group :test, :development do
  gem 'factory_girl_rails', :require => false
  gem 'ruby-debug-base19', '0.11.23' if RUBY_VERSION.include? '1.9.1'
  gem 'ruby-debug19' if RUBY_VERSION.include? '1.9'
  gem 'ruby-debug' if defined?(Rubinius).nil? && RUBY_VERSION.include?('1.8')
  gem 'launchy'
end

group :test do
  gem 'factory_girl_rails'
  gem 'fixture_builder', '~> 0.2.0'
  gem 'capybara', '~> 0.3.9'
  gem 'cucumber-rails', '0.3.2'
  gem 'rspec', '>= 2.0.0'
  gem 'rspec-rails', '>= 2.0.0'
  gem 'rcov'
  gem 'database_cleaner', '0.6.0'
  gem 'webmock', :require => false
  gem 'jasmine', :path => 'vendor/gems/jasmine', :require => false
  gem 'mongrel', :require => false if RUBY_VERSION.include? '1.8'
  gem 'rspec-instafail', '>= 0.1.7', :require => false
  gem 'fuubar'
end
