#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

ENV["RAILS_ENV"] ||= 'test'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment') unless defined?(Rails)
require 'helper_methods'
require 'spec-doc'
require 'rspec/rails'
require 'webmock/rspec'
require 'factory_girl'

include WebMock::API
WebMock::Config.instance.allow_localhost = false
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
  config.include Devise::TestHelpers, :type => :controller
  config.mock_with :rspec

  config.use_transactional_fixtures = true

  config.before(:each) do
    I18n.locale = :en
    stub_request(:post, "https://pubsubhubbub.appspot.com/")

    $process_queue = false
  end

  config.before(:each, :type => :controller) do
    self.class.render_views
  end

  config.after(:all) do
    `rm -rf #{Rails.root}/tmp/uploads/*`
  end
end

Dir["#{File.dirname(__FILE__)}/shared_behaviors/**/*.rb"].each do |f|
  require f
end

disable_typhoeus
ProcessedImage.enable_processing = false

def set_up_friends
  [local_luke, local_leia, remote_raphael]
end

def alice
  @alice ||= User.where(:username => 'alice').first
end

def bob
  @bob ||= User.where(:username => 'bob').first
end

def eve
  @eve ||= User.where(:username => 'eve').first
end

def local_luke
  @local_luke ||= User.where(:username => 'luke').first
end

def local_leia
  @local_leia ||= User.where(:username => 'leia').first
end

def remote_raphael
  @remote_raphael ||= Person.where(:diaspora_handle => 'raphael@remote.net').first
end

def photo_fixture_name
  @photo_fixture_name = File.join(File.dirname(__FILE__), 'fixtures', 'button.png')
end
