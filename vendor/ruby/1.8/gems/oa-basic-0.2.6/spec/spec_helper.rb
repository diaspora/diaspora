require 'simplecov'
SimpleCov.start
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'omniauth/basic'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include WebMock::API
end
