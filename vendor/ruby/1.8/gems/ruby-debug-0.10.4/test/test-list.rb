#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test List commands
class TestList < Test::Unit::TestCase

  @@src_dir = File.dirname(__FILE__)

  require File.join(@@src_dir, 'helper')
  include TestHelper

  # Test commands in list.rb
  def test_basic
    testname='list'
    Dir.chdir(@@src_dir) do 
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname, 
                                "--script #{script} -- gcd.rb 3 5"))
    end
  end
end
