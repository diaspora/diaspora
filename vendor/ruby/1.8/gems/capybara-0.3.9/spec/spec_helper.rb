$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'capybara'
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

Spec::Runner.configure do |config|
  config.after do
    Capybara.default_selector = :xpath
  end
end
