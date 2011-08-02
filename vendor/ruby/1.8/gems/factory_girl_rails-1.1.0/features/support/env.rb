require 'aruba/cucumber'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze

Before do
  @aruba_timeout_seconds = 3600
end
