require 'simplecov'
SimpleCov.start
require 'rspec'
require 'rack/test'
require 'omniauth/core'
require 'omniauth/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.extend  OmniAuth::Test::StrategyMacros, :type => :strategy
end

