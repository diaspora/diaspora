require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))
require 'test/unit/ui/console/testrunner'
require 'webrat'
require 'saucelabs_adapter'

Webrat.configure do |config|
  config.mode = :selenium
  config.application_framework = :rack
end

require File.join(File.dirname(__FILE__), 'sample_webrat_test')
