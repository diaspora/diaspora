source "http://rubygems.org"

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'patron', '~> 0.4'
  gem 'sinatra', '~> 1.1'
  gem 'typhoeus', '~> 0.1'
  gem 'eventmachine', '~> 0.12'
  gem 'em-http-request', '~> 0.2', :require => 'em-http'
  gem 'em-synchrony', '~> 0.2', :require => ['em-synchrony', 'em-synchrony/em-http']
end

gemspec
