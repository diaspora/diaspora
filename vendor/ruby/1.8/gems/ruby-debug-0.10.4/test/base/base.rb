#!/usr/bin/env ruby
require 'test/unit'

# Some tests of Debugger module in C extension ruby_debug 
class TestRubyDebug < Test::Unit::TestCase
  $:.unshift File.join(File.dirname(__FILE__), '..', '..', 'ext')
  require 'ruby_debug'
  $:.shift

  # test current_context
  def test_current_context
    assert_equal(false, Debugger.started?, 
                 'debugger should not initially be started.')
    Debugger.start_
    assert(Debugger.started?, 
           'debugger should now be started.')
    assert_equal(__LINE__, Debugger.current_context.frame_line)
    assert_equal(nil, Debugger.current_context.frame_args_info,
                 'no frame args info.')
    assert_equal(Debugger.current_context.frame_file, 
                 Debugger.current_context.frame_file(0))
    assert_equal(File.basename(__FILE__),
                 File.basename(Debugger.current_context.frame_file))
    assert_raises(ArgumentError) {Debugger.current_context.frame_file(1, 2)}
    assert_raises(ArgumentError) {Debugger.current_context.frame_file(10)}
    assert_equal(1, Debugger.current_context.stack_size)
    assert_equal(TestRubyDebug, Debugger.current_context.frame_class)
    assert_equal(false, Debugger.current_context.dead?, 'Not dead yet!')
    Debugger.stop
    assert_equal(false, Debugger.started?, 
                 'Debugger should no longer be started.')
  end

  # Test initial variables and setting/getting state.
  def test_debugger_base
    assert_equal(false, Debugger.started?, 
                 'Debugger should not initially be started.')
    Debugger.start_
    assert(Debugger.started?, 
           'Debugger should now be started.')
    assert_equal(false, Debugger.debug,
                 'Debug variable should not be set.')
    assert_equal(false, Debugger.post_mortem?,
                 'Post mortem debugging should not be set.')
    a = Debugger.contexts
    assert_equal(1, a.size, 
                 'There should only be one context.')
    assert_equal(Array, a.class, 
                 'Context should be an array.')
    Debugger.stop
    assert_equal(false, Debugger.started?, 
                 'debugger should no longer be started.')
  end

  # Test breakpoint handling
  def test_breakpoints
    Debugger.start_
    assert_equal(0, Debugger.breakpoints.size,
                 'There should not be any breakpoints set.')
    brk = Debugger.add_breakpoint(__FILE__, 1)
    assert_equal(Debugger::Breakpoint, brk.class,
                 'Breakpoint should have been set and returned.')
    assert_equal(1, Debugger.breakpoints.size,
                 'There should now be one breakpoint set.')
    Debugger.remove_breakpoint(0)
    assert_equal(1, Debugger.breakpoints.size,
                 'There should still be one breakpoint set.')
    Debugger.remove_breakpoint(1)
    assert_equal(0, Debugger.breakpoints.size,
                 'There should no longer be any breakpoints set.')
    Debugger.stop
  end
end

