#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'pathname'

SPEC_ROOT = Pathname.new(File.dirname(__FILE__))

prefork = proc do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  #require "rails/application"
  #Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  ENV["RAILS_ENV"] ||= 'test'
  require SPEC_ROOT.join('..', 'config', 'environment')
  require SPEC_ROOT.join('helper_methods')
  require SPEC_ROOT.join('spec-doc')

  require 'rspec/rails'
  require 'webmock/rspec'
  require 'factory_girl'
  require 'sidekiq/testing'
  require 'database_cleaner'


  Dir[SPEC_ROOT.join("shared_behaviors", "**", "*.rb")].each do |f|
    require f
  end

  ProcessedImage.enable_processing = false
  UnprocessedImage.enable_processing = false

  # require support files
  require SPEC_ROOT.join("helper_methods")
  require SPEC_ROOT.join("support", "fake_typhoeus")
  require SPEC_ROOT.join("support", "fake_http_request")
  require SPEC_ROOT.join("support", "fixture_generation")  # for jasmine fixtures
  require SPEC_ROOT.join("support", "inlined_jobs")
  require SPEC_ROOT.join("support", "user_methods")

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.use_transactional_fixtures = false
    config.mock_with :rspec
    config.render_views

    config.include HelperMethods::Rspec
    config.include Devise::TestHelpers, :type => :controller

    config.before(:suite) do
      DatabaseCleaner.orm = :active_record
      DatabaseCleaner.strategy = :transaction

      # truncate and create fresh fixtures for a clean start
      DatabaseCleaner.clean_with :truncation
      HelperMethods.build_db_fixtures
    end

    config.before(:each) do
      if example.metadata[:test_commit]
        DatabaseCleaner.strategy = :truncation
      else
        DatabaseCleaner.strategy = :transaction
        DatabaseCleaner.start
      end

      I18n.locale = :en
      stub_request(:post, "https://pubsubhubbub.appspot.com/")
      disable_typhoeus
      $process_queue = false

      Postzord::Dispatcher::Public.any_instance.stub(:deliver_to_remote)
      Postzord::Dispatcher::Private.any_instance.stub(:deliver_to_remote)
    end

    config.after(:each) do
      DatabaseCleaner.clean
      HelperMethods.build_db_fixtures if example.metadata[:test_commit]  #??
    end

    config.after(:all) do
      `rm -rf #{Rails.root}/tmp/uploads/*`
    end
  end
end


begin
  require 'spork'
  #uncomment the following line to use spork with the debugger
  #require 'spork/ext/ruby-debug'

  Spork.prefork(&prefork)
rescue LoadError
  prefork.call
end

# https://makandracards.com/makandra/950-speed-up-rspec-by-deferring-garbage-collection
# RSpec.configure do |config|
#   config.before(:all) do
#     DeferredGarbageCollection.start
#   end
#   config.after(:all) do
#     DeferredGarbageCollection.reconsider
#   end
# end
