source 'http://rubygems.org'

gem 'rails', '3.0.0'
gem 'bundler', '>= 1.0.0'

#Security
gem 'devise', :git => 'http://github.com/BadMinus/devise.git'

#Mongo
gem 'mongo_mapper', :branch => 'rails3', :git => 'http://github.com/jnunemaker/mongomapper.git'
gem 'bson_ext', '1.0.7'
gem 'bson', '1.0.7'

#Views
gem 'haml'
gem 'will_paginate', '3.0.pre2'

#Uncatagorized
gem 'roxml', :git => 'git://github.com/Empact/roxml.git'
gem 'addressable', :require => 'addressable/uri'
gem 'json'
gem 'mini_fb'

#Standards
gem 'pubsubhubbub'
gem 'redfinger', :git => 'git://github.com/rsofaer/redfinger.git'

#EventMachine
gem 'em-http-request',:git => 'git://github.com/igrigorik/em-http-request.git', :require => 'em-http'
gem 'thin'

#Websocket
gem 'em-websocket'
gem 'magent', :git => 'http://github.com/dcu/magent.git'

#File uploading
gem 'carrierwave', :git => 'git://github.com/rsofaer/carrierwave.git' , :branch => 'master' #Untested mongomapper branch
gem 'mini_magick'

group :test, :development do
  gem 'factory_girl_rails'
  gem 'ruby-debug' if RUBY_VERSION.include? "1.8"
end

group :test do
  gem 'capybara', '~> 0.3.9'
  gem 'cucumber-rails', '0.3.2'
  gem 'rspec', '>= 2.0.0.beta.17'
  gem 'rspec-rails', '2.0.0.beta.17'
  gem 'mocha'
  gem 'redgreen' if RUBY_VERSION.include? "1.8"
  gem 'autotest'
  gem 'database_cleaner'
  gem 'webmock'
end

group :development do
  gem 'nifty-generators'
end

group :deployment do
  gem 'sprinkle', :git => 'git://github.com/rsofaer/sprinkle.git'
end
