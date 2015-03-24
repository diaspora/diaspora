#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

ENV["RAILS_ENV"] ||= "test"
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
Rails.application.routes.default_url_options[:host] = AppConfig.pod_uri.host
Rails.application.routes.default_url_options[:port] = AppConfig.pod_uri.port

def set_up_friends
  [local_luke, local_leia, remote_raphael]
end

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

# Force fixture rebuild
FileUtils.rm_f(Rails.root.join("tmp", "fixture_builder.yml"))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
fixture_builder_file = "#{File.dirname(__FILE__)}/support/fixture_builder.rb"
support_files = Dir["#{File.dirname(__FILE__)}/support/**/*.rb"] - [fixture_builder_file]
support_files.each {|f| require f }
require fixture_builder_file

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.mock_with :rspec

  config.render_views
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.before(:each) do
    I18n.locale = :en
    stub_request(:post, "https://pubsubhubbub.appspot.com/")
    disable_typhoeus
    $process_queue = false
    allow_any_instance_of(Postzord::Dispatcher::Public).to receive(:deliver_to_remote)
    allow_any_instance_of(Postzord::Dispatcher::Private).to receive(:deliver_to_remote)
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

  config.include FactoryGirl::Syntax::Methods
end
