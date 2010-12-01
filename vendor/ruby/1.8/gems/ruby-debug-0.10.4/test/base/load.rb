#!/usr/bin/env ruby
require 'test/unit'

# Test of Debugger.debug_load in C extension ruby_debug.so
class TestDebugLoad < Test::Unit::TestCase

  @@src_dir = File.dirname(__FILE__)
  $:.unshift File.join(@@src_dir, '..', '..', 'ext')
  require 'ruby_debug'
  $:.shift
  
  class  << self
    def at_line(file, line)
      @@at_line = [File.basename(file), line]
    end
  end

  Debugger::PROG_SCRIPT = File.join(@@src_dir, '..', 'gcd.rb')

  class Debugger::Context
    def at_line(file, line)
      TestDebugLoad::at_line(file, line)
    end
  end

  def test_debug_load
    # Without stopping
    bt = Debugger.debug_load(Debugger::PROG_SCRIPT, false)
    assert_equal(nil, bt)
    # With stopping
    bt = Debugger.debug_load(Debugger::PROG_SCRIPT, true)
    assert_equal(nil, bt)
    assert_equal(['gcd.rb', 4], @@at_line)

    # Test that we get a proper backtrace on a script that raises 'abc'
    prog_script = File.join(@@src_dir, '..', 'raise.rb')
    bt = Debugger.debug_load(prog_script, false)
    assert_equal(bt.to_s, 'abc')
  end
end
