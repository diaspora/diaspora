unless defined?(Test)
  begin
    require 'spec/test/unit'
  rescue LoadError => ignore_if_rspec_not_installed
  end
end

if defined?(ActiveRecord::Base)
  if Rails.version.to_f >= 3.0
    require 'rails/test_help' 
  else
    require 'test_help' 
  end
else
  # I can't do rescue LoadError because in this files could be loaded
  # from rails gem (ie. load actionpack 2.3.5 if rubygems are not disabled)
  if Rails.version.to_f < 3.0
    require 'action_controller/test_process'
    require 'action_controller/integration'
  else
    require 'action_dispatch/testing/test_process'
    require 'action_dispatch/testing/integration'
  end
end

require 'cucumber/rails/test_unit'
require 'cucumber/rails/action_controller'


if (::Rails.respond_to?(:application) && !(::Rails.application.config.cache_classes)) || 
  (!(::Rails.respond_to?(:application)) && ::Rails.respond_to?(:configuration) && !(::Rails.configuration.cache_classes))
  warn "WARNING: You have set Rails' config.cache_classes to false (most likely in config/environments/cucumber.rb).  This setting is known to break Cucumber's use_transactional_fixtures method. Set config.cache_classes to true if you want to use transactional fixtures.  For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165."
end

module Cucumber #:nodoc:
  module Rails
    class World < ActionController::IntegrationTest
      include ActiveSupport::Testing::SetupAndTeardown if ActiveSupport::Testing.const_defined?("SetupAndTeardown")
      def initialize #:nodoc:
        @_result = Test::Unit::TestResult.new if defined?(Test::Unit::TestResult)
      end
    end
  end
end

World do
  Cucumber::Rails::World.new
end
