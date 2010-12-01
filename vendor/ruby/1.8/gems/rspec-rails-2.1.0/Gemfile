source "http://rubygems.org"

gem "rack", :git => "git://github.com/rack/rack.git"
gem 'rails', :path => File.expand_path("../vendor/rails", __FILE__)

%w[rspec-rails rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end

gem "cucumber", "0.8.5"
gem "aruba", "0.2.2"
gem 'webrat', "0.7.2"
gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'autotest'

platforms :mri_19 do
  gem 'ruby-debug19'
end

platforms :mri_18 do
  gem 'ruby-debug'
end
