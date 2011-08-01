source 'http://rubygems.org'

gem 'mysql2', '0.2.6'
#gem 'pg'
#gem 'sqlite3'
gem 'rails', '3.0.9'
gem 'foreigner', '0.9.1'
gem 'activerecord-import'

gem 'bundler', '>= 1.0.0'
gem 'chef', '0.9.12', :require => false
gem 'ohai', '0.5.8', :require => false #Chef dependency

gem 'nokogiri'
gem 'settingslogic', '2.0.6'

gem 'vanna', :git => "git://github.com/MikeSofaer/vanna.git"

#Security
gem 'devise', '~> 1.3.1'
gem 'devise_invitable', '0.5.0'

#Authentication
gem 'omniauth', '0.2.6'
gem 'twitter', '1.5.0'

gem 'oauth2-provider', '0.0.16'
gem 'jwt', :git => "git://github.com/zhitomirskiyi/ruby-jwt.git", :require => false

#Web
gem 'faraday'
gem 'faraday-stack'

#Views
gem 'haml', '3.1.2'
gem 'sass', '3.1.4'
gem 'will_paginate', '3.0.pre2'

#Localization
gem 'rails-i18n'
gem 'i18n-inflector-rails', '~> 1.0'

#Tags
gem 'acts-as-taggable-on', :git => 'git://github.com/diaspora/acts-as-taggable-on.git'

#Uncatagorized
gem 'roxml', :git => 'git://github.com/Empact/roxml.git', :ref => '7ea9a9ffd2338aaef5b0'
gem 'addressable', '2.2.4', :require => 'addressable/uri'
gem 'json', '1.4.6'
gem 'http_accept_language', :git => 'git://github.com/iain/http_accept_language.git', :ref => '0b78aa7849fc90cf9e12'

gem 'thin', '1.2.11', :require => false

#Websocket
gem 'em-websocket', :git => 'git://github.com/igrigorik/em-websocket', :ref => 'e278f5a1c4db60be7485'

#File uploading
gem 'carrierwave', '0.5.2'
gem "fog", '0.3.25'
gem "excon", "0.2.4"
gem 'mini_magick', '3.2'
gem 'aws', '2.3.32' # upgrade to 2.4 breaks 1.8 >.<


gem 'fastercsv', '1.5.4', :require => false
gem 'jammit', '0.5.4'
gem 'rest-client', '1.6.1'
gem 'typhoeus'

gem 'newrelic_rpm', :require => false

#Backups
gem 'cloudfiles', '1.4.10', :require => false

#Queue
gem 'resque', '1.10.0'
gem 'resque-ensure-connected'
gem 'SystemTimer', '1.2.1', :platforms => :ruby_18

group :development do
  gem 'yard'
  gem 'capistrano', '2.5.19', :require => false
  gem 'capistrano-ext', '1.2.1', :require => false
  gem 'sod', :git => "git://github.com/MikeSofaer/sod.git", :require => false
end

group :test, :development do
  #gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i  
  #gem 'guard-rspec' 
   gem 'factory_girl_rails', :require => false
  unless ENV["TRAVIS"]
    gem 'ruby-debug-base19', '0.11.23' if RUBY_VERSION.include? '1.9.1'
    gem 'ruby-debug19', :platforms => :ruby_19
    gem 'ruby-debug', :platforms => :mri_18
    gem 'linecache', '0.43', :platforms => :mri_18
  end
  gem 'launchy'
  gem 'jasmine', '1.0.2.1'
end

group :test do
  gem 'factory_girl_rails'
  gem 'fixture_builder', '~> 0.2.0'
  gem 'selenium-webdriver', '0.2.2'
  gem 'capybara', '~> 0.3.9'
  gem 'cucumber-rails', '0.3.2'
  gem 'rspec', '>= 2.0.0'
  gem 'rspec-core', '2.6.0'
  gem 'rspec-rails', '>= 2.0.0'
  gem 'rcov', :require => false
  gem 'database_cleaner', '0.6.0'
  gem 'webmock', :require => false
  gem 'mongrel', :require => false, :platforms => :ruby_18
  gem 'sqlite3', :require => false
  gem 'rspec-instafail', '>= 0.1.7', :require => false
  gem 'fuubar'

  gem 'diaspora-client', :git => 'git://github.com/diaspora/diaspora-client.git'

end
