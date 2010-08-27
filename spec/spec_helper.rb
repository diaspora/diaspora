# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.

ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
require 'rspec/rails'
require 'database_cleaner'
include Devise::TestHelpers

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
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
  def stub_sockets
    Diaspora::WebSocket.stub!(:push_to_user).and_return(true)
    Diaspora::WebSocket.stub!(:subscribe).and_return(true)
    Diaspora::WebSocket.stub!(:unsubscribe).and_return(true)
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
    Post.send(:class_variable_get, :@@queue)
  end

  def friend_users(user1, group1, user2, group2)
    request = user1.send_friend_request_to(user2.receive_url, group1.id)
    reversed_request = user2.accept_friend_request( request.id, group2.id) 
    user1.receive reversed_request.to_diaspora_xml
  end
