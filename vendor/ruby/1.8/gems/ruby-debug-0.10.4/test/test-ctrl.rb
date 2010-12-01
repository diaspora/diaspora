#!/usr/bin/env ruby

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug' ; Debugger.start

require 'test/unit'
SRC_DIR = File.dirname(__FILE__) unless 
  defined?(SRC_DIR)
%w(ext lib cli).each do |dir|
  $: <<  File.join(SRC_DIR, '..', dir)
end
require 'ruby_debug'
require File.join(SRC_DIR, '..', 'cli', 'ruby-debug')

# Test Local Control Interface
class TestCtrl < Test::Unit::TestCase

  def cheap_diff(got_lines, correct_lines, outfile)
    if correct_lines.size != got_lines.size
      puts "Size difference #{correct_lines.size} vs. #{got_lines.size}"
      File.open(outfile, 'w') {|f| f.puts got_lines}
      return false
    end
    correct_lines.each_with_index do |line, i|
      correct_lines[i].chomp!
      if got_lines[i] != correct_lines[i]
        puts "difference found at line #{i+1}"
        puts "got : #{got_lines[i]}"
        puts "need: #{correct_lines[i]}"
        File.open(outfile, 'w') {|f| f.puts got_lines}
        return false
      end
    end
  end

  require 'stringio'

  # Test initial variables and setting/getting state.
  def test_ctrl
    ENV['COLUMNS'] = '80'
    ENV['EMACS'] = nil
    testbase = 'ctrl'
    out = StringIO.new('', 'w')
    Dir.chdir(SRC_DIR) do
      script = File.join('data', "#{testbase}.cmd")
      interface = Debugger::ScriptInterface.new(script, out)
      processor = Debugger::ControlCommandProcessor.new(interface)
      processor.process_commands
      got_lines = out.string.split("\n")
      right_file = File.join('data', "#{testbase}.right")
      correct_lines = File.readlines(right_file)
      assert cheap_diff(got_lines, correct_lines, "#{testbase}.out")
    end
  end
end
