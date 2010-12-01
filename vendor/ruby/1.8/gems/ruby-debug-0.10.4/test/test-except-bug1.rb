#!/usr/bin/env ruby
require 'test/unit'
require 'rbconfig'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Bug in Post-mortem command was not being able to show
# variables on stack when stack stopped in a FIXNUM from 1/0.
class TestExceptBug1 < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  # Test post-mortem handling
  def test_pm_except_bug
    Dir.chdir(@@SRC_DIR) do 
      ENV['COLUMNS'] = '80'
      testname='except-bug1'
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} --post-mortem " + 
                                "#{testname}.rb"))
    end
  end

end
