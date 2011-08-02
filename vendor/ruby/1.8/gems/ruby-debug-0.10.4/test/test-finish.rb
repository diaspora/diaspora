#!/usr/bin/env ruby
require 'test/unit'

# require 'rubygems'
# require 'ruby-debug'; Debugger.start

# Test finish command
class TestFinish < Test::Unit::TestCase

  @@src_dir = File.dirname(__FILE__) unless 
    defined?(@@src_dir)

  require File.join(@@src_dir, 'helper')
  include TestHelper

  def test_basic
    testname='finish'
    # Ruby 1.8.6 and earlier have a trace-line number bug for return
    # statements.
#     filter = Proc.new{|got_lines, correct_lines|
#       [got_lines[31], got_lines[34]].flatten.each do |s|
#         s.sub!(/gcd.rb:\d+/, 'gcd.rb:13')
#       end
#       got_lines[32] = 'return a'
#     }
    Dir.chdir(@@src_dir) do 
      script = File.join('data', testname + '.cmd')
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} -- gcd.rb 3 5", 
                                nil, nil))
    end
  end
end
