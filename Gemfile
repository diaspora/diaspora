source 'http://rubygems.org'

gem 'rails', '>= 3.0.0'

gem 'bundler', '>= 1.0.0'
gem "chef"

#Security
gem 'devise', '1.1.3'
gem 'devise-mongo_mapper', :git => 'git://github.com/collectiveidea/devise-mongo_mapper'
gem 'devise_invitable', '~> 0.3.4'

#Authentication
gem 'omniauth'
gem 'twitter'
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
gem 'mini_fb'
gem 'http_accept_language', :git => 'http://github.com/iain/http_accept_language.git'

#Standards
gem 'pubsubhubbub'
gem 'redfinger', :git => 'git://github.com/rsofaer/redfinger.git'

#EventMachine
gem 'em-http-request',:ref => 'bf62d67fc72d6e701be5',  :git => 'git://github.com/igrigorik/em-http-request.git', :require => 'em-http'
gem 'thin'

#Websocket
gem 'em-websocket'
gem 'magent', :git => 'git://github.com/dcu/magent.git'

#File uploading
gem 'carrierwave', :git => 'git://github.com/rsofaer/carrierwave.git' , :branch => 'master' #Untested mongomapper branch
gem 'mini_magick'
gem 'aws'

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
  gem 'webmock'
end

group :deployment do
  gem 'sprinkle', :git => 'git://github.com/rsofaer/sprinkle.git'
end
