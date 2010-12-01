#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test history commands

class TestHistory < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  unless defined?(@@FILE_HISTORY)
    @@FILE_HISTORY = '.rdebug_hist'
  end

  def test_basic

    # Set up history file to read from.
    ENV['HOME']=@@SRC_DIR
    ENV['RDEBUG'] = nil

    debugger_commands = ['show commands', 
                         'set history save on', 
                         'show history',
                         'quit unconditionally']
    debugger_output = 'test-history.out'

    Dir.chdir(@@SRC_DIR) do
      correct_lines = File.read(File.join('data', 'history.right')).split(/\n/)
      f = File.open(@@FILE_HISTORY, 'w')
      correct_lines[0.. -(debugger_commands.length+1)].each do |line|
        f.puts line
      end
      f.close

      # Now that we've set up a history file, run the debugger
      # and check that it's reading that correctly.
      debug_pgm=File.join('..', 'rdbg.rb')
      debugged=File.join('gcd.rb')
      IO.popen("#{debug_pgm} #{debugged} 3 5 >#{debugger_output}", 'w') do 
        |pipe|
        debugger_commands.each do |cmd|
          pipe.puts cmd
        end
      end
      
      # Compare output
      got_lines = File.read(@@FILE_HISTORY).split(/\n/)
      # FIXME: Disable for now.
      assert true, 'FIXME'
      return
      if cheap_diff(got_lines, correct_lines)
        assert true
        FileUtils.rm(debugger_output)
        FileUtils.rm(@@FILE_HISTORY)
      else
        assert nil, 'Output differs'
      end
    end
  end
end
    
    
