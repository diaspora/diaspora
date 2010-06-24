source 'http://rubygems.org'
source 'http://gemcutter.org'

gem 'rails', '3.0.0.beta4'

gem "mongoid", :git => "git://github.com/durran/mongoid.git", :ref => "79b4d3710d17c949544f"
gem "bson_ext", "1.0.1"
gem "haml"
gem "devise", :git => "git://github.com/plataformatec/devise.git", :ref => "cfadaf80a2b7e9c0b255"
gem 'roxml', :git => "git://github.com/Empact/roxml.git"


#mai crazy async stuff
#gem 'em-synchrony',   :git => 'git://github.com/igrigorik/em-synchrony.git',    :require => 'em-synchrony/em-http'
gem 'em-http-request',:git => 'git://github.com/igrigorik/em-http-request.git', :require => 'em-http'
#gem 'rack-fiber_pool', :require => 'rack/fiber_pool'
gem 'addressable', :require => "addressable/uri"
gem 'em-websocket'
gem 'thin'


group :test do
	gem 'rspec', '>= 2.0.0.beta.12'
	gem 'rspec-rails', ">= 2.0.0.beta.8"
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
