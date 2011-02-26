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

# Force fixture rebuild
FileUtils.rm_f(File.join(Rails.root, 'tmp', 'fixture_builder.yml'))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
fixture_builder_file = "#{File.dirname(__FILE__)}/support/fixture_builder.rb"
support_files = Dir["#{File.dirname(__FILE__)}/support/**/*.rb"] - [fixture_builder_file]
support_files.each {|f| require f }
require fixture_builder_file

RSpec.configure do |config|
  config.mock_with :rspec

  config.use_transactional_fixtures = true

  config.before(:each) do
    I18n.locale = :en
    RestClient.stub!(:post).and_return(FakeHttpRequest.new(:success))

    $process_queue = false
  end
end

ImageUploader.enable_processing = false

def set_up_friends
  local_luke = Factory(:user_with_aspect, :username => "luke")
  local_leia = Factory(:user_with_aspect, :username => "leia")
  remote_raphael = Factory(:person, :diaspora_handle => "raphael@remote.net")
  connect_users_with_aspects(local_luke, local_leia)
  local_leia.activate_contact(remote_raphael, local_leia.aspects.first)
  local_luke.activate_contact(remote_raphael, local_luke.aspects.first)

  [local_luke, local_leia, remote_raphael]
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

