source 'http://rubygems.org'

gem 'rails', '3.0.3'

gem 'bundler', '>= 1.0.0'
gem "chef", :require => false

gem "nokogiri", "1.4.3.1"

#Security
gem 'devise', '1.1.3'
gem 'devise-mongo_mapper', :git => 'git://github.com/collectiveidea/devise-mongo_mapper'
gem 'devise_invitable','0.3.5'

#Authentication
gem 'omniauth', '0.1.6'
gem 'twitter', :git => 'git://github.com/jnunemaker/twitter.git', :ref => 'ef122bbb280e229ed343'

#Mongo
gem 'mongo_mapper', :branch => 'rails3', :git => 'git://github.com/jnunemaker/mongomapper.git'
gem 'bson_ext', '1.1'
gem 'bson', '1.1'

#Views
gem 'haml'
gem 'will_paginate', '3.0.pre2'

#Uncatagorized
gem 'roxml', :git => 'git://github.com/Empact/roxml.git'
gem 'addressable', :require => 'addressable/uri'
gem 'json'
gem 'http_accept_language', :git => 'git://github.com/iain/http_accept_language.git'

#Standards
gem 'pubsubhubbub'

#EventMachine
gem 'em-http-request',:ref => 'bf62d67fc72d6e701be5',  :git => 'git://github.com/igrigorik/em-http-request.git', :require => 'em-http'
gem 'thin'

#Websocket
gem 'em-websocket', :git => 'git://github.com/igrigorik/em-websocket'

#File uploading
gem 'carrierwave', :git => 'git://github.com/rsofaer/carrierwave.git' , :branch => 'master' #Untested mongomapper branch
gem 'mini_magick'
gem 'aws'
gem 'fastercsv', :require => false
gem 'jammit'
gem 'rest-client'
#Backups
gem "cloudfiles", :require => false

#Queue
gem 'resque'
gem 'SystemTimer' unless RUBY_VERSION.include? "1.9"

group :test, :development do
  gem 'factory_girl_rails'
  gem 'ruby-debug19' if RUBY_VERSION.include? "1.9"
  gem 'ruby-debug' if RUBY_VERSION.include? "1.8"
  gem 'launchy'
end

group :test do
  gem 'capybara', '~> 0.3.9'
  gem 'cucumber-rails', '0.3.2'
  gem 'rspec', '>= 2.0.0'
  gem 'rspec-rails', '>= 2.0.0'
  gem 'mocha'
  gem 'database_cleaner', '0.5.2'
  gem 'webmock', :require => false
  gem 'jasmine', :path => 'vendor/gems/jasmine', :require => false
  gem 'mongrel', :require => false if RUBY_VERSION.include? "1.8"
  gem 'rspec-instafail', :require => false
end

group :deployment do
  #gem 'sprinkle', :git => 'git://github.com/rsofaer/sprinkle.git'
end
