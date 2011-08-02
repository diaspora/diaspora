require 'simplecov'
SimpleCov.start
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'omniauth/core'
require 'omniauth/test'
require 'omniauth/openid'

RSpec.configure do |config|
  config.include WebMock::API
  config.include Rack::Test::Methods
  config.extend  OmniAuth::Test::StrategyMacros, :type => :strategy
end
