require File.expand_path(File.join(File.dirname(__FILE__),'..', 'test_helper'))
class NewRelic::LocalEnvironmentTest < Test::Unit::TestCase

  def self.teardown
    # To remove mock server instances from ObjectSpace
    ObjectSpace.garbage_collect
    super
  end
  class MockOptions
    def fetch (*args)
      1000
    end
  end
  MOCK_OPTIONS = MockOptions.new

#  def test_environment
#    e = NewRelic::LocalEnvironment.new
#    assert(nil == e.environment) # working around a bug in 1.9.1
#    assert_match /test/i, e.dispatcher_instance_id
#  end
#  def test_no_webrick
#    Object.const_set :OPTIONS, 'foo'
#    e = NewRelic::LocalEnvironment.new
#    assert(nil == e.environment) # working around a bug in 1.9.1
#    assert_match /test/i, e.dispatcher_instance_id
#    Object.class_eval { remove_const :OPTIONS }
#  end

  def test_passenger
    class << self
      module ::Passenger
        const_set "AbstractServer", 0
      end
    end
    e = NewRelic::LocalEnvironment.new
    assert_equal :passenger, e.environment
    assert_nil e.dispatcher_instance_id, "dispatcher instance id should be nil: #{e.dispatcher_instance_id}"

    NewRelic::Control.instance.instance_eval do
      @settings['app_name'] = 'myapp'
    end

    e = NewRelic::LocalEnvironment.new
    assert_equal :passenger, e.environment
    assert_nil e.dispatcher_instance_id

    ::Passenger.class_eval { remove_const :AbstractServer }
  end
  def test_snapshot
    e = NewRelic::LocalEnvironment.new
    s = e.snapshot
    assert_equal 0, s.size
    e.gather_environment_info
    s = e.snapshot
    assert_match /1\.(8\.[67]|9\.\d)/, s.assoc('Ruby version').last, s.inspect
    assert_equal 'test', s.assoc('Framework').last, s.inspect
    # Make sure the processor count is determined on linux systems
    if File.exists? '/proc/cpuinfo'
      assert s.assoc('Processors').last.to_i > 0
    end
  end


  def test_default_port
    e = NewRelic::LocalEnvironment.new
    assert_equal 3000, e.send(:default_port)
    ARGV.push '--port=3121'
    assert_equal '3121', e.send(:default_port)
    ARGV.pop
  end

end
