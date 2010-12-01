# Common setup for all test files.

begin
  require 'rubygems'
  gem 'flexmock'
rescue LoadError
  # got no gems
end

require 'flexmock/test_unit'

if RUBY_VERSION >= "1.9.0"
  class Test::Unit::TestCase
#    def passed?
#      true
#    end
  end
end

module TestMethods
  def assert_exception(ex, msg=nil, &block)
    assert_raise(ex, msg, &block)
  end
end
