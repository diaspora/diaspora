require 'rubygems'
require 'httpclient'
unless RUBY_PLATFORM =~ /java/
  require 'curb'
  require 'patron' 
  require 'em-http'
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'

require 'webmock/rspec'

require 'network_connection'

RSpec.configure do |config|
  config.include WebMock::API  
  unless NetworkConnection.is_network_available?
    warn("No network connectivity. Only examples which do not make real network connections will run.")
    no_network_connection = true
  end
  if ENV["NO_CONNECTION"] || no_network_connection
    config.filter_run_excluding :net_connect => true
  end
end

def fail()
  raise_error(RSpec::Expectations::ExpectationNotMetError)
end

def fail_with(message)
  raise_error(RSpec::Expectations::ExpectationNotMetError, message)
end

class Proc
  def should_pass
    lambda { self.call }.should_not raise_error
  end
end

def setup_expectations_for_real_example_com_request(options = {})
  defaults = { :host => "www.example.com", :port => 80, :method => "GET",
    :path => "/",
    :response_code => 200, :response_message => "OK",
    :response_body => "<title>example</title>" }
  setup_expectations_for_real_request(defaults.merge(options))
end

