require 'test/unit/testcase'

if defined?(MiniTest)
  require 'mocha/integration/mini_test'
  require File.expand_path('../mini_test_result', __FILE__)
else
  require 'test/unit/testresult'
end

module TestRunner
  def run_as_test(test_result = nil, &block)
    test_class = Class.new(Test::Unit::TestCase) do
      define_method(:test_me, &block)
    end
    test = test_class.new(:test_me)
    
    if defined?(Test::Unit::TestResult)
      test_result ||= Test::Unit::TestResult.new
      test.run(test_result) {}
      class << test_result
        attr_reader :failures, :errors
        def failure_messages
          failures.map { |failure| failure.message }
        end
        def error_messages
          errors.map { |error| error.message }
        end
      end
    else
      runner = MiniTest::Unit.new
      test.run(runner)
      test_result = MiniTestResult.new(runner, test)
    end
    
    test_result
  end
  
  def assert_passed(test_result)
    flunk "Test failed unexpectedly with message: #{test_result.failures}" if test_result.failure_count > 0
    flunk "Test failed unexpectedly with message: #{test_result.errors}" if test_result.error_count > 0
  end

  def assert_failed(test_result)
    flunk "Test passed unexpectedly" if test_result.passed?
  end

end