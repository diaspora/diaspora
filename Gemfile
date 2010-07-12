source 'http://rubygems.org'
source 'http://gemcutter.org'

gem 'rails', '3.0.0.beta4'
gem 'bundler', '0.9.26'
gem 'mongo_mapper', :git => "http://github.com/BadMinus/mongomapper.git"
gem 'devise', :git => "http://github.com/BadMinus/devise.git"
gem 'jnunemaker-validatable', :git => "http://github.com/BadMinus/validatable.git"
gem 'mongo_ext'
gem "bson_ext", "1.0.1"

gem "haml"
gem 'roxml', :git => "git://github.com/Empact/roxml.git"

gem 'gpgme'

#mai crazy async stuff
#gem 'em-synchrony',   :git => 'git://github.com/igrigorik/em-synchrony.git',    :require => 'em-synchrony/em-http'
gem 'em-http-request',:git => 'git://github.com/igrigorik/em-http-request.git', :require => 'em-http'
#gem 'rack-fiber_pool', :require => 'rack/fiber_pool'
gem 'addressable', :require => "addressable/uri"
gem 'em-websocket'
gem 'thin'
gem 'will_paginate', '3.0.pre'


group :test do
	gem 'rspec', '>= 2.0.0.beta.17'
	gem 'rspec-rails', '2.0.0.beta.17' 
  gem "mocha"
  gem 'webrat'
  gem 'redgreen'
  gem 'autotest'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :development do
  gem "nifty-generators"
  gem "ruby-debug"
end

group :deployment do
  gem 'sprinkle', :git => "git://github.com/rsofaer/sprinkle.git"
end
