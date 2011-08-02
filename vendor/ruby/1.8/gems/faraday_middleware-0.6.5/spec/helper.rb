$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start
require 'faraday_middleware'
require 'rspec'

class DummyApp
  attr_accessor :env

  def call(env)
    @env = env
  end

  def reset
    @env = nil
  end
end
