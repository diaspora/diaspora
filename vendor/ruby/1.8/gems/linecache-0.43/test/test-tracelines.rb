#!/usr/bin/env ruby
# $Id: test-tracelines.rb 51 2008-01-26 10:18:26Z rockyb $
require 'test/unit'
require 'fileutils'
require 'tempfile'

# require 'rubygems'
# require 'ruby-debug'; Debugger.init

SCRIPT_LINES__ = {} unless defined? SCRIPT_LINES__
# Test TestLineNumbers module
class TestLineNumbers1 < Test::Unit::TestCase

  @@TEST_DIR = File.expand_path(File.dirname(__FILE__))
  @@TOP_SRC_DIR = File.join(@@TEST_DIR, '..', 'lib')
  require File.join(@@TOP_SRC_DIR, 'tracelines.rb')

  @@rcov_file = File.join(@@TEST_DIR, 'rcov-bug.rb')
  File.open(@@rcov_file, 'r') {|fp|
    first_line = fp.readline[1..-2]
    @@rcov_lnums = eval(first_line, binding, __FILE__, __LINE__)
  }
  
  def test_for_file
    rcov_lines = TraceLineNumbers.lnums_for_file(@@rcov_file)
    assert_equal(@@rcov_lnums, rcov_lines)
  end

  def test_for_string
    string = "# Some rcov bugs.\nz = \"\nNow is the time\n\"\n\nz =~ \n     /\n      5\n     /ix\n"
    rcov_lines = TraceLineNumbers.lnums_for_str(string)
    assert_equal([2, 9], rcov_lines)
  end

  def test_for_string_array
    load(@@rcov_file, 0) 
    rcov_lines = 
      TraceLineNumbers.lnums_for_str_array(SCRIPT_LINES__[@@rcov_file])
    assert_equal(@@rcov_lnums, rcov_lines)
  end
end
