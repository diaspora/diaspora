require "rubygems"
require "spec"
require "spec/autorun"
require "fileutils"
require "timeout"
require "tcp_socket_extension"
require "rr"
require "lsof"

dir = File.dirname(__FILE__)
$:.unshift(File.expand_path("#{dir}/../lib"))
require "selenium_rc"

Spec::Runner.configure do |config|
  config.mock_with :rr
end
