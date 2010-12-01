# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'

module Cucumber
unless defined?(Cucumber::VERSION)
  VERSION       = '0.9.4'
  BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/cucumber')
  LIBDIR        = File.expand_path(File.dirname(__FILE__) + '/../../lib')
  JRUBY         = defined?(JRUBY_VERSION)
  IRONRUBY      = defined?(RUBY_ENGINE) && RUBY_ENGINE == "ironruby"
  WINDOWS       = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
  OS_X          = RbConfig::CONFIG['host_os'] =~ /darwin/
  WINDOWS_MRI   = WINDOWS && !JRUBY && !IRONRUBY
  RAILS         = defined?(Rails)
  RUBY_BINARY   = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
  RUBY_1_9      = RUBY_VERSION =~ /^1\.9/
  RUBY_1_8_7    = RUBY_VERSION =~ /^1\.8\.7/

  class << self
    attr_accessor :use_full_backtrace

    def file_mode(m) #:nodoc:
      RUBY_1_9 ? "#{m}:UTF-8" : m
    end
  end
  self.use_full_backtrace = false
end
end
