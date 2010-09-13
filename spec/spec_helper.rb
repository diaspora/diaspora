#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



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

  def friend_users(user1, aspect1, user2, aspect2)
    request = user1.send_friend_request_to(user2.person, aspect1)
    reversed_request = user2.accept_friend_request( request.id, aspect2.id) 
    user1.receive reversed_request.to_diaspora_xml
  end
