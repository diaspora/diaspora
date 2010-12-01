#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test simple thread commands
class TestInfoThread < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_basic
    testname='info-thread'
    Dir.chdir(@@SRC_DIR) do 
       filter = Proc.new{|got_lines, correct_lines|
         [got_lines, correct_lines].each do |a|
          a.each do |s|
            s.sub!(/Thread:0x[0-9a-f]+/, 'Thread:0x12345678')
          end
        end
       }
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- gcd.rb 3 5", nil, filter))
    end
  end
end
