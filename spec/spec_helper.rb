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

  config.mock_with :rspec

  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.orm = "mongo_mapper"

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
    stub_socket_controller 
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  config.after(:suite) do
    ctx = GPGME::Ctx.new
    keys = ctx.keys
    keys.each{|k| ctx.delete_key(k, true)}
  end
end
  def stub_socket_controller
     mock_socket_controller = mock('socket mock')
    mock_socket_controller.stub!(:incoming).and_return(true)
    mock_socket_controller.stub!(:new_subscriber).and_return(true)
    mock_socket_controller.stub!(:outgoing).and_return(true)
    mock_socket_controller.stub!(:delete_subscriber).and_return(true)
    SocketController.stub!(:new).and_return(mock_socket_controller)
  end
