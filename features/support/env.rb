# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV["RAILS_ENV"] ||= "test"
require 'cucumber/rails'

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
#require 'cucumber/rails/capybara_javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript
require 'cucumber/api_steps'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# We have a ridiculously high wait time to account for build machines of various beefiness.
# Capybara.default_wait_time = 30

# While there are a lot of failures, wait less, avoiding travis timeout
Capybara.default_wait_time = 3

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

require File.join(File.dirname(__FILE__), "..", "..", "spec", "support", "fake_redis")
require File.join(File.dirname(__FILE__), "..", "..", "spec", "helper_methods")
require File.join(File.dirname(__FILE__), "..", "..", "spec", "support","no_id_on_object")
require File.join(File.dirname(__FILE__), "..", "..", "spec", "support","user_methods")
include HelperMethods

Before do
  @no_follow_diaspora_hq_setting = AppConfig[:no_follow_diasporahq]
  AppConfig[:no_follow_diasporahq] = true
  DatabaseCleaner.clean
  Devise.mailer.deliveries = []
end

After do
  AppConfig[:no_follow_diasporahq] = @no_follow_diaspora_hq_setting
  if Capybara.current_session.driver.respond_to?(:browser)
    Capybara.reset_sessions!
    # Capybara.current_session.driver.browser.manage.delete_all_cookies
  end
end

silence_warnings do
  SERVICES['facebook'] = {'app_id' => :fake, 'app_secret' => 'sdoigjosdfijg'}
  AppConfig[:configured_services] << 'facebook'
end

require File.join(File.dirname(__FILE__), "..", "..", "spec", "support", "fake_resque")
module Resque
  def enqueue(klass, *args)
    klass.send(:perform, *args)
  end
end

# Patch aspect stream to not ajax in itself
class Stream::Aspect
  def ajax_stream?
    false
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

# class Capybara::Driver::Selenium < Capybara::Driver::Base
#   class Node < Capybara::Node
#     def [](name)
#       node.attribute(name.to_s)
#     rescue Selenium::WebDriver::Error::WebDriverError
#       nil
#     end

#     def select(option)
#       option_node = node.find_element(:xpath, ".//option[normalize-space(text())=#{Capybara::XPath.escape(option)}]") || node.find_element(:xpath, ".//option[contains(.,#{Capybara::XPath.escape(option)})]")
#       option_node.click
#     rescue
#       options = node.find_elements(:xpath, "//option").map { |o| "'#{o.text}'" }.join(', ')
#       raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
#     end
#   end
# end
