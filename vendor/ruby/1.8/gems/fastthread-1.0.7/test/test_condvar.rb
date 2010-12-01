require 'test/unit'
require 'thread'
if RUBY_PLATFORM != "java"
  $:.unshift File.expand_path( File.join( File.dirname( __FILE__ ), "../ext/fastthread" ) )
  require 'fastthread'
end

class TestCondVar < Test::Unit::TestCase
  def test_signal
    s = ""
    m = Mutex.new
    cv = ConditionVariable.new
    ready = false

    t = Thread.new do
      nil until ( Thread.pass ; m.synchronize { ready } )
      m.synchronize { s << "b" }
      cv.signal
    end

    m.synchronize do
      s << "a"
      ready = true
      cv.wait m
      assert m.locked?
      s << "c"
    end

    t.join

    assert_equal "abc", s
  end
end 

