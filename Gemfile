source 'http://rubygems.org'

gem 'rails', '3.0.0.rc'
gem 'bundler', '1.0.0.rc.5'
#gem 'rails', '3.0.0.beta4'
#gem 'bundler', '0.9.26'

#Security
gem 'devise', :git => 'http://github.com/BadMinus/devise.git'

#Mongo
gem 'mongo_mapper', :git => 'http://github.com/BadMinus/mongomapper.git'
#gem 'mongo_mapper', :git => 'http://github.com/jnunemaker/mongomapper.git'
gem 'jnunemaker-validatable', :git => 'http://github.com/BadMinus/validatable.git'
gem 'mongo_ext'
gem 'bson_ext'

#Views
gem 'haml'
gem 'will_paginate', '3.0.pre'

#Uncatagorized
gem 'roxml', :git => 'git://github.com/Empact/roxml.git'
gem 'addressable', :require => 'addressable/uri'

#Standards
gem 'pubsubhubbub'
gem 'redfinger'

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
  gem 'webrat'
  gem 'redgreen'
  gem 'autotest'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :development do
  gem 'nifty-generators'
  gem 'ruby-debug'
end

group :deployment do
  gem 'sprinkle', :git => 'git://github.com/rsofaer/sprinkle.git'
end
