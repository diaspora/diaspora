#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test (mostly) invalid breakpoint commands
class TestBrkptClassBug < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_basic
    testname='brkpt-class-bug'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- brkpt-class-bug.rb"))
    end
  end
  
end
