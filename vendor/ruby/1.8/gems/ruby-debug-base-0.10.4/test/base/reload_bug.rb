#!/usr/bin/env ruby
require 'test/unit'
class TestReloadBug < Test::Unit::TestCase
  def test_reload_bug
    top_srcdir = File.join(File.dirname(__FILE__), '..', '..')
    assert_equal({}, Debugger::source_reload)
  end
end
