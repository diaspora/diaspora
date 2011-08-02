#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test that linetracing does something.
class TestStepping < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  # Test commands in stepping.rb
  def test_basic
    testname='stepping'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- gcd.rb 3 5"))
    end
  end
end
