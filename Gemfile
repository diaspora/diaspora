source 'http://rubygems.org'

gem 'rails', '3.0.0'
gem 'bundler', '1.0.0'


#Security
gem 'devise', :git => 'http://github.com/BadMinus/devise.git'

#Mongo
#gem 'mongo_mapper', :git => 'http://github.com/BadMinus/mongomapper.git'
gem 'mongo_mapper', '0.8.4', :git => 'http://github.com/jnunemaker/mongomapper.git'
#gem 'mongo_mapper', :git => 'http://github.com/collectiveidea/mongomapper.git', :branch => 'rails3'
#gem 'jnunemaker-validatable', :git => 'http://github.com/BadMinus/validatable.git'
gem 'jnunemaker-validatable', '1.8.4', :git => 'http://github.com/jnunemaker/validatable.git'
gem 'mongo_ext'
gem 'bson_ext', '1.0.7'
gem 'bson', '1.0.7'

#Views
gem 'haml'
gem 'will_paginate', '3.0.pre2'

#Uncatagorized
gem 'roxml', :git => 'git://github.com/Empact/roxml.git'
gem 'addressable', :require => 'addressable/uri'
gem 'json'

#Standards
gem 'pubsubhubbub'
gem 'redfinger', :git => 'git://github.com/rsofaer/redfinger.git'

#EventMachine
gem 'em-http-request',:git => 'git://github.com/igrigorik/em-http-request.git', :require => 'em-http'
gem 'em-websocket'
gem 'thin'

#File uploading
gem 'carrierwave', :git => 'git://github.com/rsofaer/carrierwave.git' , :branch => 'master' #Untested mongomapper branch
gem 'mini_magick'

group :test do
	gem 'rspec', '>= 2.0.0.beta.17'
	gem 'rspec-rails', '2.0.0.beta.17' 
  gem 'mocha'
  gem 'webrat', '0.7.2.beta.1'
  gem 'redgreen'
  gem 'autotest'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'saucelabs-adapter', '= 0.8.12'
  gem 'selenium-rc'
end

group :development do
  gem 'nifty-generators'
  gem 'ruby-debug'
end

group :deployment do
  gem 'sprinkle', :git => 'git://github.com/rsofaer/sprinkle.git'
end
