require 'bundler/setup'
require 'rack'
require 'rack/test'
require 'oauth2-provider'

require 'timecop'
require 'yajl'

require "support/#{ENV["BACKEND"] || 'activerecord'}_backend"

require 'support/macros'
require 'support/factories'
require 'support/rack'

RSpec.configure do |config|
  config.before :each do
    Timecop.freeze
  end

  config.after :each do
    Timecop.return
  end

  config.include OAuth2::Provider::RSpec::Macros
  config.include OAuth2::Provider::RSpec::Factories
  config.include OAuth2::Provider::RSpec::Rack
end