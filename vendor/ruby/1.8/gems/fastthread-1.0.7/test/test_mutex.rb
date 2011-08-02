require 'test/unit'
require 'thread'
if RUBY_PLATFORM != "java"
  $:.unshift File.expand_path( File.join( File.dirname( __FILE__ ), "../ext/fastthread" ) )
  require 'fastthread'
end

class TestMutex < Test::Unit::TestCase
  def self.mutex_test( name, &body )
    define_method( "test_#{ name }" ) do
      body.call( self, Mutex.new, "" )
    end
    # at one time we also tested Mutex_m here, but it's no longer
    # part of fastthread
  end

  mutex_test( :locked_p ) do |test, m, prefix|
    test.instance_eval do
      assert_equal false, m.send( "#{ prefix }locked?" )
      m.send "#{ prefix }lock"
      assert_equal true, m.send( "#{ prefix }locked?" )
      m.send "#{ prefix }unlock"
      assert_equal false, m.send( "#{ prefix }locked?" )
    end
  end

  mutex_test( :synchronize ) do |test, m, prefix|
    test.instance_eval do
      assert !m.send( "#{ prefix }locked?" )
      m.send "#{ prefix }synchronize" do
        assert m.send( "#{ prefix }locked?" )
      end
      assert !m.send( "#{ prefix }locked?" )
    end
  end

  mutex_test( :synchronize_exception ) do |test, m, prefix|
    test.instance_eval do
      assert !m.send( "#{ prefix }locked?" )
      assert_raise ArgumentError do
        m.send "#{ prefix }synchronize" do
          assert m.send( "#{ prefix }locked?" )
          raise ArgumentError
        end
      end
      assert !m.send( "#{ prefix }locked?" )
    end
  end

  mutex_test( :mutual_exclusion ) do |test, m, prefix|
    test.instance_eval do
      s = ""

      ("a".."c").map do |c|
        Thread.new do
          Thread.pass
          5.times do
            m.send "#{ prefix }synchronize" do
              s << c
              Thread.pass
              s << c
            end
          end
        end
      end.each do |thread|
        thread.join
      end

      assert_equal 30, s.length
      assert s.match( /^(aa|bb|cc)+$/ )
    end
  end
end 

