#!/usr/bin/env ruby

require 'test/unit'

class TestCatchCommand < Test::Unit::TestCase
  
  base_dir = File.expand_path(File.join(File.dirname(__FILE__), 
                                        '..', '..', '..'))
  
  %w(ext lib cli).each do |dir|
    $: <<  File.join(base_dir, dir)
  end
  
  require File.join(base_dir, 'cli', 'ruby-debug')
  
  class MockState
    attr_accessor :message 
    def context; end
    def confirm(msg); true end
    def print(*args)
      @message = *args
    end
  end
  
  # regression test for bug #20156
  def test_catch_does_not_blow_up
    state = MockState.new
    catch_cmd = Debugger::CatchCommand.new(state)
    assert(catch_cmd.match('catch off'))
    catch(:debug_error) do
      catch_cmd.execute
    end
    assert_equal(nil, state.message)
  end

end
