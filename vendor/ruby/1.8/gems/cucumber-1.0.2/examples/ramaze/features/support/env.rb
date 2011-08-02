# See http://wiki.github.com/aslakhellesoy/cucumber/ramaze
# for more details about Ramaze with Cucumber

gem 'ramaze', '>= 2009.07'
gem 'rack-test', '>= 0.5.0'
gem 'webrat', '>= 0.5.3'

require 'ramaze'
Ramaze.options.started = true
require __DIR__("../../app.rb")

begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
require 'rack/test'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rack
end

class MyWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Ramaze::middleware
  end
end

World{MyWorld.new}
