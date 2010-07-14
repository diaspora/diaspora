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
    stub_sockets_controller
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
  def stub_sockets_controller
    mock_sockets_controller = mock('sockets mock')
    mock_sockets_controller.stub!(:incoming).and_return(true)
    mock_sockets_controller.stub!(:new_subscriber).and_return(true)
    mock_sockets_controller.stub!(:outgoing).and_return(true)
    mock_sockets_controller.stub!(:delete_subscriber).and_return(true)
    SocketsController.stub!(:new).and_return(mock_sockets_controller)
  end

  def stub_signature_verification
    Post.any_instance.stubs(:verify_signature).returns(true)
    StatusMessage.any_instance.stubs(:verify_signature).returns(true)
    Blog.any_instance.stubs(:verify_signature).returns(true)
    Bookmark.any_instance.stubs(:verify_signature).returns(true)
  end

  def unstub_mocha_stubs
    Mocha::Mockery.instance.stubba.unstub_all
 
  end
