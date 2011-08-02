#!/usr/bin/env ruby
require 'test/unit'
require 'rbconfig'

ROOT_DIR=File.dirname(__FILE__)
require File.join(ROOT_DIR, 'helper.rb')

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test Debugger.init and setting up ruby-debug variables
class TestDebuggerInit < Test::Unit::TestCase
  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)
  def test_basic
    unless File.exist?(File.join(ROOT_DIR, 'ext'))
      puts "Skipping test #{__FILE__}"
      return
    end
    debugger_output = 'test-init.out'
    Dir.chdir(@@SRC_DIR) do 
      old_emacs = ENV['EMACS']
      old_columns = ENV['COLUMNS']
      ENV['EMACS'] = nil
      ENV['COLUMNS'] = '120'
      ruby = "#{TestHelper.load_ruby} #{TestHelper.load_params}"
      IO.popen("#{ruby} ./gcd-dbg.rb 5 >#{debugger_output}", 'w') do |pipe|
        pipe.puts 'p Debugger::PROG_SCRIPT'
        pipe.puts 'show args'
        pipe.puts 'quit unconditionally'
      end
      lines = File.open(debugger_output).readlines
      ENV['EMACS'] = old_emacs
      ENV['COLUMNS'] = old_columns

      right_file = case Config::CONFIG['host_os']
                   when /^darwin/
                     'test-init-osx.right'
                   when /^cygwin/
                     'test-init-cygwin.right'
                   else
                     'test-init.right'
                   end
      expected = File.open(File.join('data', right_file)).readlines
      assert_equal(expected, lines)
      File.delete(debugger_output) if expected == lines
    end
  end
end
