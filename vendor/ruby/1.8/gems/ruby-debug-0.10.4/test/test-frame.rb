#!/usr/bin/env ruby
require 'test/unit'

# require 'rubygems'
# require 'ruby-debug'; Debugger.start(:post_mortem => true)

# Test frame commands
class TestFrame < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  # Test commands in frame.rb
  def test_basic
    testname='frame'
    # Ruby 1.8.6 and earlier have a trace-line number bug for return
    # statements.
    filter = Proc.new{|got_lines, correct_lines|
      [got_lines[11], correct_lines[11]].flatten.each do |s|
        s.sub!(/in file ".*gcd.rb/, 'in file "gcd.rb')
      end
    }
    Dir.chdir(@@SRC_DIR) do 
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- gcd.rb 3 5",
                                nil, filter))
    end
  end
end
