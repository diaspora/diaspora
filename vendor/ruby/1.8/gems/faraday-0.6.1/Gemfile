source "http://rubygems.org"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'patron', '~> 0.4', :platforms => :ruby
  gem 'sinatra', '~> 1.1'
  gem 'typhoeus', '~> 0.2', :platforms => :ruby
  gem 'excon', '~> 0.5.8'
  gem 'em-http-request', '~> 0.3', :require => 'em-http', :platforms => :ruby
  gem 'em-synchrony', '~> 0.2', :require => ['em-synchrony', 'em-synchrony/em-http'], :platforms => :ruby_19
  gem 'webmock'
  # ActiveSupport::JSON will be used in ruby 1.8 and Yajl in 1.9; this is to test against both adapters
  gem 'activesupport', '~> 2.3.8', :require => nil, :platforms => [:ruby_18, :jruby]
  gem 'yajl-ruby', :require => 'yajl', :platforms => :ruby_19
end

gemspec
