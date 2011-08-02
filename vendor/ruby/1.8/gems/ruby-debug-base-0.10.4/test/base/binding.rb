#!/usr/bin/env ruby

require 'test/unit'

# Test binding_n command
class TestBinding < Test::Unit::TestCase

  SRC_DIR = File.expand_path(File.dirname(__FILE__)) unless 
    defined?(SRC_DIR)
  %w(ext lib).each do |dir|
    $:.unshift File.join(SRC_DIR, '..', '..', dir)
  end
  require File.join(SRC_DIR, '..', '..', 'lib', 'ruby-debug-base')
  $:.shift; $:.shift

  def test_basic
    def inside_fn
      s = 'some other string'
      b2 = Kernel::binding_n(1)
      y2 = eval('s', b2)
      assert_equal('this is a test', y2)
    end
    s = 'this is a test'
    Debugger.start
    b = Kernel::binding_n(0)
    y = eval('s', b)
    assert_equal(y, s)
    inside_fn
    Debugger.stop
  end
end
