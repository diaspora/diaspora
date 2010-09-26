#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.

ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
require 'rspec/rails'
require 'database_cleaner'
require 'webmock/rspec'

include Devise::TestHelpers
include WebMock

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.mock_with :rspec

  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.orm = "mongo_mapper"

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    stub_signature_verification

  end

  config.before(:each) do
    DatabaseCleaner.start
    stub_sockets
    User.stub!(:allowed_email?).and_return(:true)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

ImageUploader.enable_processing = false

  def stub_sockets
    Diaspora::WebSocket.stub!(:queue_to_user).and_return(true)
    Diaspora::WebSocket.stub!(:subscribe).and_return(true)
    Diaspora::WebSocket.stub!(:unsubscribe).and_return(true)
  end

  def unstub_sockets
    Diaspora::WebSocket.unstub!(:queue_to_user)
    Diaspora::WebSocket.unstub!(:subscribe)
    Diaspora::WebSocket.unstub!(:unsubscribe)
  end

  def stub_signature_verification
    (get_models.map{|model| model.camelize.constantize} - [User]).each do |model|
      model.any_instance.stubs(:verify_signature).returns(true)
    end
  end

  def unstub_mocha_stubs
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def get_models
    models = []
    Dir.glob( File.dirname(__FILE__) + '/../app/models/*' ).each do |f|
      models << File.basename( f ).gsub( /^(.+).rb/, '\1')
    end
    models
  end

  def message_queue
    User::QUEUE
  end

  def friend_users(user1, aspect1, user2, aspect2)
    request = user1.send_friend_request_to(user2.person, aspect1)
    reversed_request = user2.accept_friend_request( request.id, aspect2.id)
    user1.reload
    user1.receive reversed_request.to_diaspora_xml
    user1.reload
    aspect1.reload
    user2.reload
    aspect2.reload
  end

  def stub_success(address = 'abc@example.com')
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    if host.include?("joindiaspora.com")
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => finger_xrd)
      stub_request(:get, "http://#{host}/hcard/users/4c8eccce34b7da59ff000002").to_return(:status => 200, :body => hcard_response)
    else
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => nonseed_finger_xrd)
      stub_request(:get, 'http://evan.status.net/hcard').to_return(:status => 200, :body => evan_hcard)
    end
  end

  def stub_failure(address = 'abc@example.com')
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 500)
  end

  def host_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/host_xrd').read
  end

  def finger_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/finger_xrd').read
  end

  def hcard_response
    File.open(File.dirname(__FILE__) + '/fixtures/hcard_response').read
  end

  def nonseed_finger_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/nonseed_finger_xrd').read
  end

  def evan_hcard
    File.open(File.dirname(__FILE__) + '/fixtures/evan_hcard').read
  end
