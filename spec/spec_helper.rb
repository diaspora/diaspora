#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment') unless defined?(Rails)
require 'helper_methods'
require 'rspec/rails'
require 'webmock/rspec'
require 'factory_girl'

include Devise::TestHelpers
include WebMock::API
include HelperMethods

`rm #{File.join(Rails.root, 'tmp', 'fixture_builder.yml')}`
#
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  config.use_transactional_fixtures = true

  config.before(:each) do
    I18n.locale = :en
    RestClient.stub!(:post).and_return(FakeHttpRequest.new(:success))

    $process_queue = false
  end
end

def alice
  #users(:alice)
  User.where(:username => 'alice').first
end

def bob
  #users(:bob)
  User.where(:username => 'bob').first
end

def eve
  #users(:eve)
  User.where(:username => 'eve').first
end
module Diaspora::WebSocket
  def self.redis
    FakeRedis.new
  end
end
class FakeRedis
  def rpop(*args)
    true
  end
  def llen(*args)
    true
  end
  def lpush(*args)
    true
  end
end

ImageUploader.enable_processing = false

class FakeHttpRequest
  def initialize(callback_wanted)
    @callback = callback_wanted
    @callbacks = []
  end

  def callbacks=(rs)
    @callbacks += rs.reverse
  end

  def response
    @callbacks.pop unless @callbacks.nil? || @callbacks.empty?
  end

  def response_header
    self
  end

  def method_missing(method)
    self
  end

  def post(opts = nil);
    self
  end

  def get(opts = nil)
    self
  end

  def publish(opts = nil)
    self
  end

  def callback(&b)
    b.call if @callback == :success
  end

  def errback(&b)
    b.call if @callback == :failure
  end
end
