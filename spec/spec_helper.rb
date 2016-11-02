#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

ENV["RAILS_ENV"] ||= "test"

require 'coveralls'
Coveralls.wear!('rails')

require File.join(File.dirname(__FILE__), "..", "config", "environment")
require Rails.root.join("spec", "helper_methods")
require Rails.root.join("spec", "spec-doc")
require "rspec/rails"
require "webmock/rspec"
require "factory_girl"
require "sidekiq/testing"
require "shoulda/matchers"

include HelperMethods

Dir["#{File.dirname(__FILE__)}/shared_behaviors/**/*.rb"].each do |f|
  require f
end

ProcessedImage.enable_processing = false
UnprocessedImage.enable_processing = false

def alice
  @alice ||= User.find_by(username: "alice")
end

def bob
  @bob ||= User.find_by(username: "bob")
end

def eve
  @eve ||= User.find_by(username: "eve")
end

def local_luke
  @local_luke ||= User.find_by(username: "luke")
end

def local_leia
  @local_leia ||= User.find_by(username: "leia")
end

def remote_raphael
  @remote_raphael ||= Person.find_by(diaspora_handle: "raphael@remote.net")
end

def peter
  @peter ||= User.find_by(username: "peter")
end

def photo_fixture_name
  @photo_fixture_name = File.join(File.dirname(__FILE__), "fixtures", "button.png")
end

def jwks_file_path
  @jwks_file = File.join(File.dirname(__FILE__), "fixtures", "jwks.json")
end

def valid_client_assertion_path
  @valid_client_assertion = File.join(File.dirname(__FILE__), "fixtures", "valid_client_assertion.txt")
end

def client_assertion_with_tampered_sig_path
  @client_assertion_with_tampered_sig = File.join(File.dirname(__FILE__), "fixtures",
                                                  "client_assertion_with_tampered_sig.txt")
end

def client_assertion_with_nonexistent_kid_path
  @client_assertion_with_nonexistent_kid = File.join(File.dirname(__FILE__), "fixtures",
                                                     "client_assertion_with_nonexistent_kid.txt")
end

def client_assertion_with_nonexistent_client_id_path
  @client_assertion_with_nonexistent_client_id = File.join(File.dirname(__FILE__), "fixtures",
                                                           "client_assertion_with_nonexistent_client_id.txt")
end

# Force fixture rebuild
FileUtils.rm_f(Rails.root.join("tmp", "fixture_builder.yml"))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
fixture_builder_file = "#{File.dirname(__FILE__)}/support/fixture_builder.rb"
support_files = Dir["#{File.dirname(__FILE__)}/support/**/*.rb"] - [fixture_builder_file]
support_files.each {|f| require f }
require fixture_builder_file

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.mock_with :rspec

  config.example_status_persistence_file_path = "tmp/rspec-persistance.txt"

  config.render_views
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.before(:each) do
    I18n.locale = :en
    stub_request(:post, "https://pubsubhubbub.appspot.com/")
    $process_queue = false
    allow(Workers::SendPublic).to receive(:perform_async)
    allow(Workers::SendPrivate).to receive(:perform_async)
  end

  config.expect_with :rspec do |expect_config|
    expect_config.syntax = :expect
  end

  config.after(:all) do
    `rm -rf #{Rails.root}/tmp/uploads/*`
  end

  # Reset overridden settings
  config.after(:each) do
    AppConfig.reset_dynamic!
  end

  # Reset test mails
  config.after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  # Reset gon
  config.after(:each) do
    RequestStore.store[:gon].gon.clear unless RequestStore.store[:gon].nil?
  end

  config.include FactoryGirl::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

shared_context suppress_csrf_verification: :none do
  before do
    ActionController::Base.allow_forgery_protection = true
  end
end
