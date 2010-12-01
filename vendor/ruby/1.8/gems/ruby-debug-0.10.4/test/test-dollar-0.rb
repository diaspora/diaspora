#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test --no-stop and $0 setting.
class TestDollar0 < Test::Unit::TestCase
  
  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_basic
    testname='breakpoints'
    Dir.chdir(@@SRC_DIR) do 
      home_save = ENV['HOME']
      ENV['HOME'] = '.'
      filter = Proc.new{|got_lines, correct_lines|
        [got_lines, correct_lines].flatten.each do |s|
          s.gsub!(/.*dollar-0.rb$/, 'dollar-0.rb')
        end
      }

      assert_equal(true, 
                   run_debugger('dollar-0', 
                                '-nx --no-stop ./dollar-0.rb',
                                nil, filter, false, '../bin/rdebug'))
      # Ruby's __FILE__ seems to prepend ./ when no directory was added.
      assert_equal(true, 
                   run_debugger('dollar-0a', 
                                '-nx --no-stop dollar-0.rb',
                                nil, filter, false, '../bin/rdebug'))
      # Ruby's __FILE__ seems to prepend ./ when no directory was added.
      assert_equal(true, 
                   run_debugger('dollar-0b', 
                                '-nx --no-stop ' + 
                                File.join('..', 'test', 'dollar-0.rb'),
                                nil, filter, false, '../bin/rdebug'))
      ENV['HOME'] = home_save
    end
  end
end
