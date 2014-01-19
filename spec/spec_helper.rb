#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

prefork = proc do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  #require "rails/application"
  #Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  ENV["RAILS_ENV"] ||= 'test'
  require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
  require Rails.root.join('spec', 'helper_methods')
  require Rails.root.join('spec', 'spec-doc')
  require 'rspec/rails'
  require 'webmock/rspec'
  require 'factory_girl'
  require 'sidekiq/testing'

  include HelperMethods

  Dir["#{File.dirname(__FILE__)}/shared_behaviors/**/*.rb"].each do |f|
    require f
  end

  ProcessedImage.enable_processing = false
  UnprocessedImage.enable_processing = false

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

  # Force fixture rebuild
  FileUtils.rm_f(Rails.root.join('tmp', 'fixture_builder.yml'))

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

    config.before(:each) do
      I18n.locale = :en
      stub_request(:post, "https://pubsubhubbub.appspot.com/")
      disable_typhoeus
      $process_queue = false
      Postzord::Dispatcher::Public.any_instance.stub(:deliver_to_remote)
      Postzord::Dispatcher::Private.any_instance.stub(:deliver_to_remote)
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
RSpec.configure do |config|
  config.before(:all) do
    DeferredGarbageCollection.start
  end
  config.after(:all) do
    DeferredGarbageCollection.reconsider
  end
end
