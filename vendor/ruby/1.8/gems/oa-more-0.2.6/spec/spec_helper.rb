require 'simplecov'
SimpleCov.start
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'omniauth/more'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include WebMock::API
end
