#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test 'edit' command handling.
class TestEdit < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_basic
    testname='edit'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join('data', testname + '.cmd')
      ENV['EDITOR']='echo FAKE-EDITOR '
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- gcd.rb 3 5"))
    end
  end
end
