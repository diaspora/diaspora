require 'rubygems'

prefork = proc do
  ENV["RAILS_ENV"] ||= "test"
  require 'cucumber/rails'

  require 'capybara/rails'
  require 'capybara/cucumber'
  require 'capybara/session'
  #require 'cucumber/rails/capybara_javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript

  # Ensure we know the appservers port
  Capybara.server_port = 9887


  # Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
  # order to ease the transition to Capybara we set the default here. If you'd
  # prefer to use XPath just remove this line and adjust any selectors in your
  # steps to use the XPath syntax.
  Capybara.default_selector = :css

  # We have a ridiculously high wait time to account for build machines of various beefiness.
  # Capybara.default_wait_time = 30

  # While there are a lot of failures, wait less, avoiding travis timeout
  Capybara.default_wait_time = 15

  # If you set this to false, any error raised from within your app will bubble
  # up to your step definition and out to cucumber unless you catch it somewhere
  # on the way. You can make Rails rescue errors and render error pages on a
  # per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
  #
  # If you set this to true, Rails will rescue all errors and render error
  # pages, more or less in the same way your application would behave in the
  # default production environment. It's not recommended to do this for all
  # of your scenarios, as this makes it hard to discover errors in your application.
  ActionController::Base.allow_rescue = false

  require 'database_cleaner'
  require 'database_cleaner/cucumber'
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.orm = "active_record"
  Cucumber::Rails::World.use_transactional_fixtures = false

  require File.join(File.dirname(__FILE__), "database_cleaner_patches")
  require File.join(File.dirname(__FILE__), "integration_sessions_controller")
  require File.join(File.dirname(__FILE__), "poor_mans_webmock")

  require 'sidekiq/testing/inline'

  require Rails.root.join('spec', 'helper_methods')
  require Rails.root.join('spec', 'support', 'inlined_jobs')
  require Rails.root.join('spec', 'support', 'user_methods')
  include HelperMethods

  # require 'webmock/cucumber'
  # WebMock.disable_net_connect!(:allow_localhost => true)


  #hax to get rubymine to run spork, set RUBYMINE_HOME in your .bash_profile
  if ENV["RUBYMINE_HOME"]
    puts "Loading rubymine spork extensions"
    $:.unshift(File.expand_path("rb/testing/patch/common", ENV["RUBYMINE_HOME"]))
    $:.unshift(File.expand_path("rb/testing/patch/bdd", ENV["RUBYMINE_HOME"]))
  end
end

each_run = proc do
  Before do
    DatabaseCleaner.clean
    Devise.mailer.deliveries = []
  end

  After do
    if Capybara.current_session.driver.respond_to?(:browser)
      Capybara.reset_sessions!
      # Capybara.current_session.driver.browser.manage.delete_all_cookies
    end
  end

  Before('@localserver') do
    TestServerFixture.start_if_needed
    CapybaraSettings.instance.save
    Capybara.current_driver = :selenium
    Capybara.run_server = false
  end

  After('@localserver') do
    CapybaraSettings.instance.restore
  end
end

begin
  require 'spork'
  #uncomment the following line to use spork with the debugger
  #require 'spork/ext/ruby-debug'

  Spork.prefork(&prefork)
  Spork.each_run(&each_run)
rescue LoadError
  prefork.call
  each_run.call
end

# give firefox more time to complete requests
# http://ihswebdesign.com/knowledge-base/fixing-selenium-timeouterror/
After do |scenario|
  if scenario.exception.is_a? Timeout::Error
    # restart Selenium driver
    Capybara.send(:session_pool).delete_if { |key, value| key =~ /selenium/i }
  end
end

# # https://makandracards.com/makandra/950-speed-up-rspec-by-deferring-garbage-collection
# require File.join(File.dirname(__FILE__), "..", "..", "spec", "support", "deferred_garbage_collection")
# Before do
#   DeferredGarbageCollection.start
# end
# After do
#   DeferredGarbageCollection.reconsider
# end
