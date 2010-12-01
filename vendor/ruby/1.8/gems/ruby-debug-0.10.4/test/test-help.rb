#!/usr/bin/env ruby

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug' ; Debugger.start

require 'test/unit'
SRC_DIR = File.dirname(__FILE__) unless 
  defined?(SRC_DIR)
%w(ext lib cli).each do |dir|
  $:.unshift  File.join(SRC_DIR, '..', dir)
end
require 'ruby_debug'

require File.join(SRC_DIR, '..', 'cli', 'ruby-debug')
$:.shift; $:.shift; $:.shift

def cheap_diff(got_lines, correct_lines)
  puts got_lines if $DEBUG
  correct_lines.each_with_index do |line, i|
    correct_lines[i].chomp!
    if got_lines[i] != correct_lines[i]
      puts "difference found at line #{i+1}"
      puts "got : #{got_lines[i]}"
      puts "need: #{correct_lines[i]}"
      return false
    end
    if correct_lines.size != got_lines.size
      puts("difference in number of lines: " + 
           "#{correct_lines.size} vs. #{got_lines.size}")
      return false
    end
    return true
  end
end

# Test Help commands
class TestHelp < Test::Unit::TestCase
  require 'stringio'

  # Test initial variables and setting/getting state.
  def test_basic
    testbase = 'help'
    op = StringIO.new('', 'w')
    Dir.chdir(SRC_DIR) do 
      script = File.join('data', "#{testbase}.cmd")
      Debugger.const_set('Version', 'unit testing')
      Debugger.run_script(script, op)
      got_lines = op.string.split("\n")
      right_file = File.join('data', "#{testbase}.right")
      correct_lines = File.readlines(right_file)
      result = cheap_diff(got_lines, correct_lines)
      unless result
        puts '-' * 80
        puts got_lines 
        puts '-' * 80
      end
      assert result 
    end
  end
end
