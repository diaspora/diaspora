#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test info variables command
class TestInfoVar < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_info_variables

    Dir.chdir(@@SRC_DIR) do 

      filter = Proc.new{|got_lines, correct_lines|
        [got_lines[13-1], correct_lines[13-1]].each do |s|
          s.sub!(/Mine:0x[0-9,a-f]+/, 'Mine:')
        end
        [got_lines, correct_lines].each do |a|
          a.each do |s|
            s.sub!(/Lousy_inspect:0x[0-9,a-f]+/, 'Lousy_inspect:')
            s.sub!(/UnsuspectingClass:0x[0-9,a-f]+/, 'UnsuspectingClass:')
          end
        end
      }

      testname='info-var'
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- info-var-bug.rb",
                                nil, filter))
      testname='info-var-bug2'
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- info-var-bug2.rb",
                                nil))

    end
  end
end
