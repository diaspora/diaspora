require File.expand_path(File.join(File.dirname(__FILE__),'..','test_helper'))

class NewRelic::DelayedJobInstrumentationTest < Test::Unit::TestCase
  def test_skip_logging_if_no_logger_found
    Object.const_set('Delayed', Module.new) unless defined?(Delayed)
    ::Delayed.const_set('Worker', Class.new)
    
    NewRelic::Agent.stubs(:logger).raises(NoMethodError,
                                            'tempoarily not allowed')
    NewRelic::Agent.stubs(:respond_to?).with(:logger).returns(false)
    
    assert DependencyDetection.detect!
    
    Object.class_eval { remove_const('Delayed') }
  end
end
