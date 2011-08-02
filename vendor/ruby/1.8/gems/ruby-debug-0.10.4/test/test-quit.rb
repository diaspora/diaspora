#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test Quit command
class TestQuit < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_basic
    testname='quit'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join('data', testname + '.cmd')
#       filter = Proc.new{|got_lines, correct_lines|
#         [got_lines[0], correct_lines[0]].each do |s|
#           s.sub!(/tdebug.rb:\d+/, 'rdebug:999')
#         end
#       }
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- null.rb"))
    end
  end
end
